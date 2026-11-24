# PostHog Helm Chart

A Helm chart for deploying the open-source self-hosted [PostHog](https://posthog.com) stack on Kubernetes.

> **Scope of this chart**
> This chart is intentionally scoped to **product analytics + feature flags**.
> Session replay, error tracking, AI features and logs/traces ingestion are not implemented in this chart version.

## Prerequisites

- Kubernetes >= 1.24
- Helm >= 3.11 (chart was linted with Helm 4.x as well)
- An external PostgreSQL cluster (version 15+)
- An external ClickHouse cluster (an Altinity `ClickHouseInstallation` is recommended)
- An external S3-compatible object store (e.g. MinIO)
- An ingress controller (tested with ingress-nginx)

## Architecture

The chart deploys the following groups of workloads:

| Group | Components |
|-------|------------|
| **Core app** | `web`, `worker`, `temporal-worker` |
| **Ingestion** | `capture`, `ingestion-general`, `property-defs-rs` |
| **Feature flags / surveys** | `feature-flags`, `hypercache-server` |
| **CDP / webhooks** | `plugins` |
| **Realtime** | `livestream` |
| **PersonHog pipeline** | `personhog-replica`, `personhog-router`, `personhog-router-leader`, `personhog-leader`, `personhog-writer`, `personhog-identity`, `personhog-publisher`, `personhog-changelog-relay` |
| **Browser automation** | `browserless` |
| **Internal stateful** | Redis 7, Valkey, ZooKeeper, Redpanda, etcd, Temporal |
| **Init / migration jobs** | Kafka topic init, PersonHog etcd init, Django/ClickHouse migrations, async migrations check, PersonHog tables readiness |

`property-defs-rs` is a Kafka consumer and PostgreSQL writer. Its query API intentionally receives no production traffic upstream, so there is no `PROPERTY_DEFS_RPC_URL`; its Service exposes health and metrics endpoints. PersonHog etcd initialization Jobs include the Helm release revision in their names, so upgrades do not patch immutable Job pod templates.

## Image pinning

Every container image is pinned by immutable digest in `values.yaml`. There is no use of `latest` or moving tags in the default configuration. When upgrading PostHog, update the digest of every related image together.

## External dependencies

### PostgreSQL

The chart expects an external PostgreSQL cluster and a pre-created Kubernetes Secret containing the full `DATABASE_URL`:

```yaml
databaseUrl:
  existingSecret: posthog-app-secrets
  key: DATABASE_URL
```

The `externalPostgresql` block is used for Temporal and for the `personhog-tables-ready` init job:

```yaml
externalPostgresql:
  host: postgres.example.com
  port: 5432
  database: posthog
  user: posthog
  password:
    existingSecret: posthog-postgres
    key: password
  sslMode: require
```

Two PostgreSQL databases are required:
- `posthog` for the application
- `temporal` + `temporal_visibility` for Temporal (if internal Temporal is used)

### ClickHouse

```yaml
externalClickhouse:
  host: clickhouse-posthog-clickhouse
  database: posthog
  user: default
  secure: false
  verify: false
```

The external cluster must contain PostHog's upstream cluster definitions, Kafka named collections, profiles and executable UDF configuration. The SCOUT-80 Altinity installation also provisions the UDF binaries and format schemas.

### Object storage

```yaml
externalObjectStorage:
  endpoint: http://minio.example.com:9000
  publicEndpoint: https://posthog.example.com
  region: us-east-1
  bucket: posthog
  forcePathStyle: true
  accessKey:
    existingSecret: posthog-s3
    key: AWS_ACCESS_KEY_ID
  secretKey:
    existingSecret: posthog-s3
    key: AWS_SECRET_ACCESS_KEY
```

The bucket must be created and configured outside the chart. `publicEndpoint` is the endpoint origin without the bucket name; the S3 SDK appends the bucket. Public read access is handled by ingress-nginx, which must proxy `/posthog` to the S3 API without stripping that prefix.

## Required secrets

Create at least these secrets before installing:

| Secret | Keys | Used by |
|--------|------|---------|
| `posthog-secrets` | `SECRET_KEY`, `ENCRYPTION_SALT_KEYS`, optionally `INTERNAL_REQUEST_TOKEN`, `INTERNAL_API_SECRET` | All core workloads |
| `posthog-postgres` | `password` | PostgreSQL connection, Temporal, init jobs |
| `posthog-s3` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | Object storage |
| `posthog-smtp` (optional) | `SMTP_PASSWORD` | Email invites / password reset |
| `posthog-browserless` (optional) | `BROWSERLESS_TOKEN` | Browserless Chromium token (falls back to `posthog-secrets`) |
| `posthog-livestream` (optional) | `LIVESTREAM_JWT_SECRET` | Livestream JWT secret (falls back to `posthog-secrets`) |

## Installation

```bash
helm upgrade --install posthog ./charts/posthog \
  --namespace posthog --create-namespace \
  -f values.yaml \
  -f my-overrides.yaml
```

### Minimal override example

```yaml
siteUrl: "https://posthog.example.com"

secretKey:
  existingSecret: posthog-secrets
encryptionSaltKeys:
  existingSecret: posthog-secrets
internalRequestToken:
  existingSecret: posthog-secrets
  key: INTERNAL_REQUEST_TOKEN

databaseUrl:
  existingSecret: posthog-app-secrets
  key: DATABASE_URL

externalPostgresql:
  host: postgres.example.com
  user: posthog
  password:
    existingSecret: posthog-postgres
    key: password

externalClickhouse:
  host: clickhouse.example.com

externalObjectStorage:
  endpoint: http://minio.example.com:9000
  publicEndpoint: https://posthog.example.com
  bucket: posthog
  accessKey:
    existingSecret: posthog-s3
  secretKey:
    existingSecret: posthog-s3

email:
  enabled: true
  host: smtp.example.com
  port: 587
  user: posthog@example.com
  password:
    existingSecret: posthog-smtp
  fromEmail: posthog@example.com
```

## Ingress

The chart creates one Ingress resource per route group. Public paths match the upstream Hobby Caddy routes:

| Path | Destination |
|------|-------------|
| `/` | web (8000) |
| `/e`, `/i/v0`, `/i/v1/analytics/events`, `/batch`, `/capture` | capture (3000) |
| `/flags`, `/api/feature_flag/local_evaluation` | feature-flags (3001) |
| `/array`, `/surveys`, `/api/surveys` | hypercache-server (3002) |
| `/public/webhooks`, `/public/m` | plugins (6738) |
| `/livestream` | livestream (8080) |

## Network policies

Default-deny NetworkPolicies are installed for both ingress and egress. Selective rules allow:

- DNS resolution to the cluster's `kube-dns` service in `kube-system` on ports 53/UDP and TCP
- Pod-to-pod traffic inside the namespace
- Traffic from ingress-nginx on the ports declared in `ingress.routes`
- External PostgreSQL, ClickHouse (HTTP 8123 and native 9000 by default), Kafka, S3 and SMTP when the corresponding `networkPolicy.*CIDRs` lists are configured

## Monitoring

Set `monitoring.serviceMonitor.enabled=true` to create Prometheus `ServiceMonitor` resources. Only Redpanda (admin port `/metrics`) and etcd (client port `/metrics`) are enabled out of the box, because the other services either expose no metrics endpoint or require a dedicated exporter / metrics port configuration.

## Upgrading

1. Review the upstream PostHog `docker-compose.hobby.yml` changes.
2. Update all pinned image digests together in `values.yaml`.
3. Bump the chart version in `Chart.yaml` and update `CHANGELOG.md`.
4. Run `helm lint` and `helm template` with the CI values.
5. Upgrade the release.

## Limitations

- ClickHouse is external. PostHog-specific cluster configuration and executable UDF assets must be provisioned with that cluster.
- Temporal visibility uses the same external PostgreSQL. For high-availability Temporal, run a separate Temporal cluster.
- Redis, Valkey, Redpanda, ZooKeeper and etcd are single-node by default. Scale them via `replicaCount` and persistence settings only after validating the upstream constraints.
- Session replay, error tracking, AI and logs/traces are not implemented in this chart version.

## License

This chart is released under the same license as the blockscout/helm-charts repository.
