# blockscout-ens

A Helm chart to deploy Blockscout ENC application to kubernetes cluster

## Prerequisites

- Kubernetes 1.19+
- Helm 3+
<!-- - PostgreSQL version 12 to 14
- Redis (if accounts blockscout feature is enabled) -->

## Get Helm Repository Info

```console
helm repo add blockscout https://blockscout.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Helm Chart

```console
helm install [RELEASE_NAME] blockscout/blockscout-ens
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
helm upgrade [RELEASE_NAME] blockscout/blockscout-ens
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values blockscout/blockscout-ens
```
This chart does not contain default values for required ENV variables.
