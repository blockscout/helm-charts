# Pganalyzer

## Get Helm Repository Info

```console
helm repo add blockscout https://blockscout.github.io/helm-charts
helm repo update
```
## Docs

- [Pganalyzer](https://pganalyze.com/docs)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"quay.io/pganalyze/collector"` | Image repository |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| image.tag | string | `"stable"` | Image tag |
| imagePullSecrets | list | `[]` |  |
| replicaCount | int | `1` |  |
| api.key | string | `""` | Pganalyzer API key |
| api.systemId | string | `""` | Pganalyzer system ID |
| db.host | string | `nil` | Database host |
| db.name | string | `nil` | Comma separated list of databases to monitor |
| db.password | string | `nil` |  |
| db.username | string | `nil` |  |
| extraEnv | object | `{}` | Extra environment variables to set |
| affinity | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
