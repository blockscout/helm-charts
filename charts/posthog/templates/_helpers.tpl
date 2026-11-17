{{/*
Expand the name of the chart.
*/}}
{{- define "posthog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "posthog.fullname" -}}
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
{{- define "posthog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "posthog.labels" -}}
helm.sh/chart: {{ include "posthog.chart" . }}
{{ include "posthog.selectorLabels" . }}
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
{{- define "posthog.selectorLabels" -}}
app.kubernetes.io/name: {{ include "posthog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "posthog.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "posthog.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference helpers
*/}}
{{- define "posthog.image" -}}
{{- $root := index . 0 -}}
{{- $image := index . 1 -}}
{{- $tag := $image.tag | required "image tag is required" -}}
{{- $repository := $image.repository -}}
{{- if $image.digest -}}
{{- printf "%s@%s" $repository $image.digest -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Database URL secret reference helper
*/}}
{{- define "posthog.databaseUrl" -}}
valueFrom:
  secretKeyRef:
    name: {{ .Values.databaseUrl.existingSecret | required "databaseUrl.existingSecret is required" | quote }}
    key: {{ .Values.databaseUrl.key | quote }}
{{- end }}

{{/*
Browserless token secret reference helper
*/}}
{{- define "posthog.browserlessToken" -}}
{{- $secret := .Values.browserless.token.existingSecret | default .Values.secretKey.existingSecret -}}
{{- $key := .Values.browserless.token.key | default .Values.secretKey.key -}}
valueFrom:
  secretKeyRef:
    name: {{ $secret | quote }}
    key: {{ $key | quote }}
{{- end }}

{{/*
Livestream JWT secret reference helper
*/}}
{{- define "posthog.livestreamJwtSecret" -}}
{{- $secret := .Values.livestream.jwtSecret.existingSecret | default .Values.secretKey.existingSecret -}}
{{- $key := .Values.livestream.jwtSecret.key | default .Values.secretKey.key -}}
valueFrom:
  secretKeyRef:
    name: {{ $secret | quote }}
    key: {{ $key | quote }}
{{- end }}

{{/*
Kafka brokers helper
*/}}
{{- define "posthog.kafka.brokers" -}}
{{- if .Values.externalKafka.enabled -}}
{{- .Values.externalKafka.brokers -}}
{{- else -}}
{{- printf "%s-redpanda:9092" (include "posthog.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Kafka URL helper (used by PostHog Django settings)
*/}}
{{- define "posthog.kafka.url" -}}
{{- if .Values.externalKafka.enabled -}}
{{- .Values.externalKafka.brokers -}}
{{- else -}}
{{- printf "kafka://%s-redpanda:9092" (include "posthog.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
ClickHouse host helper
*/}}
{{- define "posthog.clickhouse.host" -}}
{{- if .Values.externalClickhouse.enabled -}}
{{- .Values.externalClickhouse.host -}}
{{- else -}}
{{- printf "%s-clickhouse" (include "posthog.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Redis URL helper
*/}}
{{- define "posthog.redis.url" -}}
{{- printf "redis://%s-redis:6379/" (include "posthog.fullname" .) -}}
{{- end }}

{{/*
Component labels helper
*/}}
{{- define "posthog.componentLabels" -}}
{{ include "posthog.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Component selector labels helper
*/}}
{{- define "posthog.componentSelectorLabels" -}}
{{ include "posthog.selectorLabels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
