# Changelog

All notable changes to this chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-11-17

### Added
- Initial PostHog Helm chart for open-source self-hosted deployment on Kubernetes.
- Support for product analytics and feature flags only. Session replay, error tracking, AI and logs/traces are not implemented in this chart version.
- Deployments: web, worker, temporal-django-worker, capture, feature-flags, hypercache-server, plugins, ingestion-general, property-defs-rs, livestream, browserless.
- PersonHog persons pipeline: replica, router, router-leader, leader, writer, identity, publisher, changelog-relay.
- Internal stateful dependencies: Redis 7, Valkey, ClickHouse, ZooKeeper, Redpanda (Kafka replacement), etcd, Temporal.
- External PostgreSQL and external S3-compatible object storage support.
- nginx-ingress routing for all public paths without Caddy.
- NetworkPolicies with default-deny ingress/egress and selective allow rules.
- All container images pinned by immutable digest.
- Helm hooks for Kafka topic init, PersonHog etcd init, Django/ClickHouse migrations, async migrations check and PersonHog tables readiness.
- Readiness/liveness probes for all workloads.
- Optional Prometheus ServiceMonitor resources.
- Optional separate secrets for browserless and livestream tokens.
