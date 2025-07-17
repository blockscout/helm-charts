# ChangeLog

## 3.3.0

### Feature

- Redirect ingress now supports multiple domains (this is breaking change, if config.redirect is used)

## 3.2.3

### Feature

- Add ability to set deployment annotations

## 3.2.2

### Fix

- Adding missing stats pod annotations

## 3.2.1

### Fix

- Fixing nft resizer worker concurrency value in deployment

## 3.2.0

### Feature

- Adding parameter for nft resizer worker concurrency

## 3.1.0

### Feature

- Add ability to set base path for stats component

## 3.0.0

### Feature

- Change default docker registry for backend image from DockerHub to GH ContainerRegistry. Works only for 8.0.0 blockscout version, if you are using any previous version, do not update helm chart to 3.x
- API-only image removal, now configuration of API-only mode can be made in runtime with DISABLE_INDEXER=true
- Add prometheus rules for missing batch alerts

## 2.2.0

### Feature

- Shared certificate for frontend and backend if they run on same domain
- Adding possibility to redirect to frontend domain from any other domain (Helpfull when moving from one domain to another)

## 2.1.1

### Fix

- Adding imagePullSecret to backend migration job

## 2.1.0

### Feature

- Pointing sitemap.xml to frontend instance as it now served by frontend since 1.38.0

## 2.0.3

### Fix

- Fixing sitemap.xml ingress pathType to pass NGINX validation

## 2.0.2

### Fix

- IPFS Gateway configuration for NFT resizer

## 2.0.1

### Fix

- Fix Monitoring when separateApi is enabled

## 2.0.0

### Major Update

- Updated app version to 7.0.0
- Changed API healthcheck path (breaking change)
- Update supported Postgresql versions

## 1.11.1

### Feature

- Health path for blackbox exporter as parameter

## 1.11.0

### Feature

- Pinned stats version to 2.4 and made `STATS__BLOCKSCOUT_API_URL` env mandatory

## 1.10.0

### Feature

- ServiceMonitor for blackbox probing blockscout backend

## 1.9.2

### Fix

- Adding ONE missing variable (BLOCKSCOUT_HOST) to indexer pod when running separate from API.

## 1.9.1

### Fix

- Adding missing variables to indexer pod when running separate from API.

## 1.9.0

### Feature

- Adding support for NFT storage
- Adding security context for migration jobs

## 1.8.0

### Feature

- Custom volume mount for blockscout backend deployment

## 1.7.1

### Fix

- Service selector labels now support fullnameOverride variable instead of Release.Name

## 1.7.0

### Feature

- Whitelist for metrics paths to avoid public access in secure environment

## 1.6.11

### Fix

- Stats: Rewrite check for conditional env, allow 'main', and 'latest' tags.

## 1.6.10

### Feature

- Support new stats (2.2.0) with required env

## 1.6.9

### Fix

- Enable stats probes by default

## 1.6.8

### Fix

- Rollback to 1.6.6 as pre-install hook deletes secret because of bug in helm

## 1.6.7

### Fix

- Adding hook annotations for blockscout secret to be created with migration job on new installation

## 1.6.6

### Fix

- Replace MODE with APPLICATION_MODE variable.

## 1.6.5

### Fix

- Fixing setting MODE env variable for indexer application.

## 1.6.4

### Feature

- Adding MODE env variable for backend to distinguish API/indexer applications.

## 1.6.3

### Feature

- Adding extraEnv for user-ops indexer and stats services deployments

### Fixes

- Fixed a typo in stats and user-ops indexer, where ```replicaCount``` was named ```replicasCount``` and was thus marked as undefined.

## 1.6.2

### Features

- Adding services (name service, user-ops) configuration to .config section

## 1.6.1

### Features

- Expose new backend ingress path - public metrics

## 1.6.0

### Features

- Adding possibility to run separate api and indexer deployment. More information on this can be found [here](https://docs.blockscout.com/for-developers/information-and-settings/separate-indexer-web-app-and-api). The minimum required backend version is 6.6.0

## 1.5.1

### Fixes

- Do not refer to `envFromSecret` when not defined for backend/frontend

## 1.5.0

### Feature

- Add PodMonitor for frontend

## 1.4.4

### Feature

- Add `extraEnv` and `envFrom` for backend/frontend to refer to an existing Secret/ConfigMap
- Create Secrets for backend/frontend only when data is specified

## 1.4.3

### Fixes

- Making stats configmap name unique

## 1.4.2

### Fixes

- Fixing stats url condition in frontend deployment

## 1.4.1

### Fixes

- Fixing stats volume attachment

## 1.4.0

### Feature

- Adding user-ops-indexer service

## 1.3.4

### Fixes

- Fixed custom TLS secret name reference for frontend and stats ingresses

## 1.3.3

### Feature

- Custom secret name for ingress TLS

## 1.3.2

### Fixes

- Dual token condition for gnosis chain

## 1.3.1

### Feature

- Adding dualToken parameter for networks like Gnosis Chain

## 1.3.0

### Feature

- Update blockscout app to 5.3.0
- Decrease blockscout frontend initialDelaySeconds to 30

## 1.2.0

### Feature

- Stats currency symbol now is passed from ```config.network.currency.symbol``` (Stats version 1.4.1 and above required)

## 1.1.4

### Fixes

- Adjust default frontend resource
- Increase default servicemonitor timeout

## 1.1.3

### Fixes

- Fixing path for auth

## 1.1.2

### Fixes

- Fixing path to /sitemap.xml

## 1.1.1

### Fixes

- Fixing path to /socket

## 1.1.0

### Features

- Updating ingress paths for frontend and backend (this change requires at least v1.9.0 of frontend and 5.2.2 for backend)

## 1.0.4

### Features

- Added README, CHANGELOG

### Fixes

- Fixed fixing prometheus serviceMonitor always on [issue](https://github.com/blockscout/helm-charts/issues/1)
