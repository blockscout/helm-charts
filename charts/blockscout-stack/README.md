# blockscout-stack

![Version: 1.0.4](https://img.shields.io/badge/Version-1.0.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.2.2](https://img.shields.io/badge/AppVersion-5.2.2-informational?style=flat-square)

A Helm chart to deploy Blockscout stack ([backend](https://github.com/blockscout/blockscout), [frontend](https://github.com/blockscout/frontend) and [stats](https://github.com/blockscout/blockscout-rs/tree/main/stats)) to kubernetes cluster

## Prerequisites

- Kubernetes 1.19+
- Helm 3+
- PostgreSQL version 12 to 14
- Redis (if accounts blockscout feature is enabled)

## Get Helm Repository Info

```console
helm repo add blockscout https://blockscout.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Helm Chart

```console
helm install [RELEASE_NAME] blockscout/blockscout-stack
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
helm upgrade [RELEASE_NAME] blockscout/blockscout-stack
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values blockscout/blockscout-stack
```
This chart does not contain default values for required ENV variables, before running it you should read carefully docs for [blockscout](https://docs.blockscout.com/setup/env-variables), [frontend](https://github.com/blockscout/frontend/blob/main/docs/ENVS.md) and [stats](https://github.com/blockscout/blockscout-rs/tree/main/stats)
