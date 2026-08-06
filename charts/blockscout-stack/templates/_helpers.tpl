{{/*
Expand the name of the chart.
*/}}
{{- define "blockscout-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "blockscout-stack.fullname" -}}
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
{{- define "blockscout-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "blockscout-stack.labels" -}}
helm.sh/chart: {{ include "blockscout-stack.chart" . }}
{{ include "blockscout-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "blockscout-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "blockscout-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "blockscout-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "blockscout-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Merge global and component pod annotations.
Component annotations override global keys.
Usage:
  include "blockscout-stack.podAnnotations" (dict "root" . "component" .Values.frontend)
*/}}
{{- define "blockscout-stack.podAnnotations" -}}
{{- $root := .root -}}
{{- $component := .component | default dict -}}
{{- $annotations := mergeOverwrite (dict) ($root.Values.podAnnotations | default dict) ($component.podAnnotations | default dict) -}}
{{- with $annotations -}}
{{- toYaml . -}}
{{- end -}}
{{- end }}

{{/*
Merge global and component pod labels.
Component labels override global keys.
Usage:
  include "blockscout-stack.podLabels" (dict "root" . "component" .Values.frontend)
*/}}
{{- define "blockscout-stack.podLabels" -}}
{{- $root := .root -}}
{{- $component := .component | default dict -}}
{{- $labels := mergeOverwrite (dict) ($root.Values.podLabels | default dict) ($component.podLabels | default dict) -}}
{{- with $labels -}}
{{- toYaml . -}}
{{- end -}}
{{- end }}
