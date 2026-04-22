#!/usr/bin/env python3
"""
Sync environment variable documentation from upstream Blockscout repos
into values.schema.json for the blockscout-stack Helm chart.

Fetches ENVS.md and DEPRECATED_ENVS.md from the blockscout/frontend repo,
parses markdown tables, and updates the JSON Schema with known env var
properties (descriptions, examples, defaults).

Usage:
    python sync-env-schema.py \
        --schema-path ../values.schema.json \
        --registry-dir env-registry/ \
        --frontend-tag v1.38.0
"""

import argparse
import json
import logging
import re
import sys
import urllib.request
from datetime import date
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger(__name__)

RAW_GH = "https://raw.githubusercontent.com"
FRONTEND_ENVS_PATH = "docs/ENVS.md"
FRONTEND_DEPRECATED_PATH = "docs/DEPRECATED_ENVS.md"


def fetch_file(repo: str, ref: str, path: str) -> str | None:
    """Fetch a file from GitHub raw content. Returns None on failure."""
    url = f"{RAW_GH}/{repo}/{ref}/{path}"
    log.info("Fetching %s", url)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "sync-env-schema/1.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode("utf-8")
    except Exception as e:
        log.warning("Failed to fetch %s: %s", url, e)
        return None


def parse_markdown_tables(content: str) -> list[dict]:
    """
    Parse all markdown tables from content.
    Returns list of dicts with keys from the header row.
    """
    rows = []
    lines = content.split("\n")
    headers = None

    for line in lines:
        line = line.strip()
        if not line.startswith("|"):
            headers = None
            continue

        cells = [c.strip() for c in line.split("|")]
        # split on | gives empty strings at start/end
        cells = cells[1:-1] if len(cells) > 2 else cells

        if not cells:
            continue

        # Detect separator row (e.g. | --- | --- |)
        if all(re.match(r"^-+:?$|^:?-+:?$", c) for c in cells):
            continue

        if headers is None:
            headers = [h.strip().lower().replace(" ", "_") for h in cells]
            continue

        if headers:
            row = {}
            for i, h in enumerate(headers):
                row[h] = cells[i].strip() if i < len(cells) else ""
            rows.append(row)

    return rows


def clean_type(raw_type: str) -> str:
    """Remove backticks and normalize type string."""
    return raw_type.strip("`").strip()


def clean_value(val: str) -> str:
    """Remove backticks and dash placeholders."""
    val = val.strip("`").strip()
    if val == "-":
        return ""
    return val


def is_env_var_name(name: str) -> bool:
    """Check if a string looks like an environment variable name (UPPER_CASE_WITH_UNDERSCORES)."""
    return bool(re.match(r"^[A-Z][A-Z0-9_]+$", name))


def parse_frontend_envs(content: str) -> dict[str, dict]:
    """Parse ENVS.md into a dict of env var name -> metadata."""
    rows = parse_markdown_tables(content)
    envs = {}

    for row in rows:
        name = row.get("variable", "").strip("`").strip()
        if not name or not is_env_var_name(name):
            continue

        env_type = clean_type(row.get("type", ""))
        description = row.get("description", "").strip()
        compulsoriness = row.get("compulsoriness", "").strip()
        default = clean_value(row.get("default_value", ""))
        example = clean_value(row.get("example_value", ""))
        version = clean_value(row.get("version", ""))

        envs[name] = {
            "type": env_type,
            "description": description,
            "required": compulsoriness.lower() == "required",
            "default": default,
            "example": example,
            "since": version,
            "deprecated": False,
        }

    return envs


def parse_frontend_deprecated(content: str) -> dict[str, dict]:
    """Parse DEPRECATED_ENVS.md into a dict of env var name -> metadata."""
    rows = parse_markdown_tables(content)
    envs = {}

    for row in rows:
        name = row.get("variable", "").strip("`").strip()
        if not name:
            continue

        env_type = clean_type(row.get("type", ""))
        description = row.get("description", "").strip()
        compulsoriness = row.get("compulsoriness", "").strip()
        default = clean_value(row.get("default_value", ""))
        example = clean_value(row.get("example_value", ""))
        introduced = clean_value(row.get("introduced_in_version", ""))
        deprecated_in = clean_value(row.get("deprecated_in_version", ""))
        comment = row.get("comment", "").strip()

        desc = description
        if comment:
            desc = f"[DEPRECATED: {comment}] {description}"

        envs[name] = {
            "type": env_type,
            "description": desc,
            "required": False,
            "default": default,
            "example": example,
            "since": introduced,
            "deprecated": True,
            "deprecatedSince": deprecated_in,
        }

    return envs


def compute_diff(
    old_registry: dict[str, dict], new_envs: dict[str, dict]
) -> tuple[list[str], list[str], list[str]]:
    """Compare old and new env registries. Returns (added, removed, changed)."""
    old_names = set(old_registry.keys())
    new_names = set(new_envs.keys())

    added = sorted(new_names - old_names)
    removed = sorted(old_names - new_names)
    changed = []
    for name in sorted(old_names & new_names):
        if old_registry[name] != new_envs[name]:
            changed.append(name)

    return added, removed, changed


def env_to_schema_property(env: dict) -> dict:
    """Convert an env metadata dict to a JSON Schema property."""
    prop: dict = {"type": "string"}

    desc = env.get("description", "")
    if env.get("deprecated"):
        desc = f"DEPRECATED. {desc}"
    if desc:
        prop["description"] = desc

    if env.get("default"):
        prop["default"] = env["default"]

    if env.get("example"):
        prop["examples"] = [env["example"]]

    if env.get("deprecated"):
        prop["deprecated"] = True

    return prop


def update_schema(schema: dict, component: str, envs: dict[str, dict]) -> None:
    """Update the schema's env properties for a given component."""
    comp = schema.setdefault("properties", {}).setdefault(component, {})
    comp_props = comp.setdefault("properties", {})
    env_obj = comp_props.setdefault("env", {})

    # Preserve the base type and additionalProperties
    env_obj.setdefault("type", "object")
    env_obj.setdefault("additionalProperties", {})

    # Build properties from parsed envs
    properties = {}
    for name in sorted(envs.keys()):
        properties[name] = env_to_schema_property(envs[name])

    env_obj["properties"] = properties


def update_source_metadata(schema: dict, component: str, version: str) -> None:
    """Update x-env-sources metadata in the schema root."""
    sources = schema.setdefault("x-env-sources", {})
    sources[component] = {
        "version": version,
        "updatedAt": date.today().isoformat(),
    }


def load_registry(path: Path) -> dict:
    """Load env registry from JSON file."""
    if path.exists():
        with open(path) as f:
            return json.load(f)
    return {}


def save_registry(path: Path, data: dict) -> None:
    """Save env registry to JSON file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2, sort_keys=True, ensure_ascii=False)
        f.write("\n")


def print_changelog(
    component: str, added: list[str], removed: list[str], changed: list[str]
) -> None:
    """Print human-readable changelog to stdout."""
    if not added and not removed and not changed:
        log.info("[%s] No changes detected", component)
        return

    print(f"\n## {component} env changes\n")
    if added:
        print(f"### Added ({len(added)})")
        for name in added:
            print(f"  + {name}")
    if removed:
        print(f"### Removed ({len(removed)})")
        for name in removed:
            print(f"  - {name}")
    if changed:
        print(f"### Changed ({len(changed)})")
        for name in changed:
            print(f"  ~ {name}")
    print()


def main():
    parser = argparse.ArgumentParser(description="Sync env var schema from upstream repos")
    parser.add_argument(
        "--schema-path",
        required=True,
        help="Path to values.schema.json",
    )
    parser.add_argument(
        "--registry-dir",
        required=True,
        help="Directory for env registry cache files",
    )
    parser.add_argument(
        "--frontend-tag",
        help="Frontend repo tag/ref to fetch ENVS.md from (e.g. v1.38.0 or main)",
    )
    parser.add_argument(
        "--frontend-repo",
        default="blockscout/frontend",
        help="Frontend GitHub repo (default: blockscout/frontend)",
    )
    args = parser.parse_args()

    schema_path = Path(args.schema_path)
    registry_dir = Path(args.registry_dir)

    # Load existing schema
    if schema_path.exists():
        with open(schema_path) as f:
            schema = json.load(f)
    else:
        log.error("Schema file not found: %s", schema_path)
        sys.exit(1)

    any_success = False

    # --- Frontend ---
    if args.frontend_tag:
        ref = args.frontend_tag
        repo = args.frontend_repo

        envs_content = fetch_file(repo, ref, FRONTEND_ENVS_PATH)
        deprecated_content = fetch_file(repo, ref, FRONTEND_DEPRECATED_PATH)

        if envs_content is None and deprecated_content is None:
            log.warning("Could not fetch any frontend env docs for %s@%s", repo, ref)
        else:
            any_success = True

            # Parse
            frontend_envs = {}
            if envs_content:
                frontend_envs = parse_frontend_envs(envs_content)
                log.info("Parsed %d env vars from ENVS.md", len(frontend_envs))

            deprecated_envs = {}
            if deprecated_content:
                deprecated_envs = parse_frontend_deprecated(deprecated_content)
                log.info("Parsed %d deprecated env vars", len(deprecated_envs))

            # Merge: active envs + deprecated envs
            all_envs = {**deprecated_envs, **frontend_envs}

            # Diff against registry
            registry_path = registry_dir / "frontend-envs.json"
            old_registry = load_registry(registry_path)
            added, removed, changed = compute_diff(old_registry, all_envs)
            print_changelog("frontend", added, removed, changed)

            # Update schema
            update_schema(schema, "frontend", all_envs)
            update_source_metadata(schema, "frontend", ref)

            # Save registry
            save_registry(registry_path, all_envs)

    if not any_success and (args.frontend_tag):
        log.error("All sources failed")
        sys.exit(1)

    # Write updated schema
    with open(schema_path, "w") as f:
        json.dump(schema, f, indent=2, ensure_ascii=False)
        f.write("\n")

    log.info("Schema updated: %s", schema_path)


if __name__ == "__main__":
    main()
