# Eth RPC exporter

## Get Helm Repository Info

```console
helm repo add blockscout https://blockscout.github.io/helm-charts
helm repo update
```
## Docs

- [Eth RPC expoter](https://github.com/blockscout/prometheus-exporters/tree/main/eth-rpc-exporter)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config.rpcUrl | string | `"http://localhost:8545"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/blockscout/eth-rpc-exporter"` |  |
| image.tag | string | `"main"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `999` |  |
| prometheusRule.enabled | bool | `true` | Enable prometheus rules, rule are specified with `prometheusRule.rules` |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `999` |  |
| service.port | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `true` |  |
| serviceMonitor.interval | int | `60` |  |
| serviceMonitor.path | string | `"/metrics"` |  |
| serviceMonitor.timeout | int | `30` |  |
| tolerations | list | `[]` |  |
