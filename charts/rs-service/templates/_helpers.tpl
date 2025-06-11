{{/*
Expand the name of the chart.
*/}}
{{- define "rs-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rs-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rs-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rs-service.labels" -}}
helm.sh/chart: {{ include "rs-service.chart" . }}
{{ include "rs-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rs-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rs-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component specific labels
*/}}
{{- define "rs-service.componentLabels" -}}
{{- $component := index . 0 }}
{{- $root := index . 1 }}
helm.sh/chart: {{ include "rs-service.chart" $root }}
{{ include "rs-service.componentSelectorLabels" . }}
{{- if $root.Chart.AppVersion }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end }}

{{/*
Component specific selector labels
*/}}
{{- define "rs-service.componentSelectorLabels" -}}
{{- $component := index . 0 }}
{{- $root := index . 1 }}
app.kubernetes.io/name: {{ include "rs-service.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rs-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rs-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get image repository with global registry prefix
*/}}
{{- define "rs-service.imageRepository" -}}
{{- $repo := index . 0 }}
{{- $root := index . 1 }}
{{- if $root.Values.global.imageRegistry }}
{{- printf "%s/%s" $root.Values.global.imageRegistry $repo }}
{{- else }}
{{- $repo }}
{{- end }}
{{- end }}

{{/*
Get image tag with fallback to chart app version
*/}}
{{- define "rs-service.imageTag" -}}
{{- $tag := index . 0 }}
{{- $root := index . 1 }}
{{- $tag | default $root.Chart.AppVersion }}
{{- end }}

{{/*
Create ingress hostname
*/}}
{{- define "rs-service.ingressHostname" -}}
{{- $ingress := index . 0 }}
{{- $root := index . 1 }}
{{- if $ingress.hostname }}
{{- $ingress.hostname }}
{{- else }}
{{- printf "%s.%s" $root.Values.service.type "example.com" }}
{{- end }}
{{- end }}

{{/*
Merge environment variables from different sources
*/}}
{{- define "rs-service.environmentVariables" -}}
{{- $env := index . 0 | default dict }}
{{- $envFromSecret := index . 1 | default dict }}
{{- $root := index . 2 }}
{{- range $key, $value := $env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- range $key, $value := $envFromSecret }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $value }}
      key: {{ $key }}
{{- end }}
{{- end }}

{{/*
Get resource configuration with fallback to common
*/}}
{{- define "rs-service.resources" -}}
{{- $resources := index . 0 }}
{{- $root := index . 1 }}
{{- if $resources }}
{{- toYaml $resources }}
{{- else }}
{{- toYaml $root.Values.service.resources }}
{{- end }}
{{- end }}

{{/*
Get service port configuration
*/}}
{{- define "rs-service.servicePort" -}}
{{- $service := index . 0 }}
{{- $root := index . 1 }}
{{- $service.port | default 8050 }}
{{- end }}

{{/*
Get target port configuration
*/}}
{{- define "rs-service.targetPort" -}}
{{- $service := index . 0 }}
{{- $root := index . 1 }}
{{- $service.targetPort | default $service.port | default 8050 }}
{{- end }}

{{/*
Get liveness probe configuration
*/}}
{{- define "rs-service.livenessProbe" -}}
{{- $probe := index . 0 }}
{{- $root := index . 1 }}
{{- if $probe }}
{{- toYaml $probe }}
{{- else }}
{{- toYaml $root.Values.service.livenessProbe }}
{{- end }}
{{- end }}

{{/*
Get readiness probe configuration
*/}}
{{- define "rs-service.readinessProbe" -}}
{{- $probe := index . 0 }}
{{- $root := index . 1 }}
{{- if $probe }}
{{- toYaml $probe }}
{{- else }}
{{- toYaml $root.Values.service.readinessProbe }}
{{- end }}
{{- end }} 