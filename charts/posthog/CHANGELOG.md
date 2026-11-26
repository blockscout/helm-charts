# Changelog

All notable changes to this chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2026-11-26

### Fixed
- Point the separate Logs ClickHouse client to the configured external ClickHouse cluster and reuse its existing Secret reference for authentication.

## [0.1.2] - 2026-11-25

### Fixed
- Wire capture's named Rust Kafka producer to the configured Redpanda/Kafka brokers instead of its upstream `kafka:9092` default.

## [0.1.1] - 2026-11-25

### Fixed
- Bind Redpanda RPC to all pod interfaces instead of the Service ClusterIP.
- Use the upstream `cdp-api` plugin server mode.
- Leave the OTLP endpoint unset when telemetry is disabled, including Rust workloads.
- Send `X-Forwarded-Proto: https` with web health probes to avoid TLS redirects.
- Increase ZooKeeper probe timeouts for the Java status command; cap its Java heap at 512 MB with a 1 Gi container limit to prevent repeated OOM kills.
- Point Python CDP clients to the in-cluster plugins API instead of the upstream default hostname.
- Skip the legacy npm GeoIP plugin preinstall during organization creation so an unreachable registry cannot block signup; the built-in GeoIP database remains enabled.
- Raise the async migration check to 1 Gi request / 2 Gi limit to prevent OOM kills during Django startup.
- Wire all named Node.js Kafka producer slots to the configured brokers and override the service-link Redis port with a numeric value.
- Use the image-baked MaxMind database for feature flags.
- Enable PostgreSQL TLS for Temporal and pass separate host/port values to Python Temporal clients.
- Raise the Celery worker to 2 Gi request / 4 Gi limit and limit prefork concurrency to two workers.
- Preserve libpq `sslmode=require` semantics for Node.js PostgreSQL clients without changing Django's URL.
- Provision the pinned GeoIP database for Node.js workloads and wire the remaining legacy Kafka endpoints.
- Add the separate Cyclotron queue database migration Job using migrations pinned to the PostHog source revision.

## [0.1.0] - 2026-11-17

### Added
- Initial PostHog Helm chart for open-source self-hosted deployment on Kubernetes.
- Support for product analytics and feature flags only. Session replay, error tracking, AI and logs/traces are not implemented in this chart version.
- Deployments: web, worker, temporal-django-worker, capture, feature-flags, hypercache-server, plugins, ingestion-general, property-defs-rs, livestream, browserless.
- PersonHog persons pipeline: replica, router, router-leader, leader, writer, identity, publisher, changelog-relay.
- External ClickHouse integration; internal stateful dependencies: Redis 7, Valkey, ZooKeeper, Redpanda (Kafka replacement), etcd, Temporal.
- External PostgreSQL and external S3-compatible object storage support.
- nginx-ingress routing for all public paths without Caddy.
- NetworkPolicies with default-deny ingress/egress and selective allow rules.
- All container images pinned by immutable digest.
- Helm hooks for Kafka topic init, Django/ClickHouse migrations, async migrations check and PersonHog tables readiness; a regular PersonHog etcd initialization Job avoids `--wait` deadlock.
- Readiness/liveness probes where supported by the upstream workloads.
- Optional Prometheus ServiceMonitor resources.
- Optional separate secrets for browserless and livestream tokens.
