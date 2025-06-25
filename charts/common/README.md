# common Helm Chart

Universal Helm chart for deploying any single service.

## Overview

This chart allows you to deploy any of the services with a unified configuration approach. Instead of maintaining separate charts for each service, this chart provides a universal template that can be configured to deploy any service.

## Prerequisites

- Kubernetes 1.19+
- Helm 3+

## Get Helm Repository Info

```console
helm repo add blockscout https://blockscout.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Helm Chart

```console
helm install [RELEASE_NAME] blockscout/common
```

_See [configuration](#configuration) below._
_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Helm Chart

```console
helm uninstall [RELEASE_NAME]
```

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._
This removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] blockscout/common
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values blockscout/common
```

## Troubleshooting

### Common Issues

1. **Missing image repository**: Ensure you set `image.repository` to the correct service image.

2. **Service not accessible**: Check that the service port matches the port your application listens on.

3. **Environment variables**: Verify that environment variable names match what your service expects.

4. **Resource limits**: Adjust resource requests/limits based on your service requirements.

### Debug Commands

```bash
# Check pod logs
kubectl logs -l app.kubernetes.io/name=commons

# Check service endpoints
kubectl get endpoints

# Check ingress
kubectl describe ingress

# Validate Helm template
helm template my-service blockscout/common --debug
```

## Contributing

When adding support for new commons:

1. Test the service with this chart
2. Ensure proper defaults are set
