# Changelog

## [1.2.5] - 2025-11-12

### Added
- Support for initContainers to run initialization tasks before the main container

## [1.2.4] - 2025-10-22

### Added
- Support custom runtimeClassName

## [1.2.3] - 2025-09-22

### Added
- Support privileged run

## [1.2.2] - 2025-09-22

### Fixed
- Fixing default job annotations

## [1.2.1] - 2025-09-22

### Added
- Adding job annotations

## [1.2.0] - 2025-08-05

### Added
- Added support for Job resources

## [1.1.1] - 2025-06-27

### Fixed
- Fixed issue with configmap keys being uppercase

## [1.1.0] - 2025-06-26

### Fixed
- Fixed issue with nested `valueFrom` in `env`

## [1.0.0] - 2025-06-04

### Added
- Created universal Helm chart `common` for deploying all micro-services

### Features
- **Uniform structure**: All services use common settings and patterns
- **Flexible configuration**: Support for simple services and multi-component systems
- **Security**: Built-in security settings (non-root, read-only filesystem)
- **Automation**: Automatic creation of Service, Deployment, Ingress, ConfigMap
- **Monitoring**: Support for ServiceMonitor for Prometheus
- **Scaling**: Configuration of the number of replicas for each service
- **gRPC support**: Special support for gRPC services
- **Configuration files**: Automatic creation of ConfigMap from configuration

### Templates
- `serviceaccount.yaml` - Creation of Service Account
- `service.yaml` - Universal Service resources for all services
- `deployment.yaml` - Universal Deployment resources
- `configmap.yaml` - ConfigMap for services with configuration files
- `ingress.yaml` - Ingress resources with TLS support
- `servicemonitor.yaml` - ServiceMonitor for Prometheus
- `cronjob.yaml` - CronJob resources for periodic tasks
- `_helpers.tpl` - Universal helper functions

### Security
- All pods run as non-root user (UID 1000)
- Read-only root filesystem by default
- All capabilities dropped
- Support for ImagePullSecrets for private registries

### Documentation
- Detailed README.md with examples of usage
- Examples of configurations for different scenarios
- Description of all available parameters
- Troubleshooting section