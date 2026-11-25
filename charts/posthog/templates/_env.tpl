{{/*
Common environment variables shared by PostHog workloads.
*/}}
{{- define "posthog.commonEnv" -}}
{{- $fullname := include "posthog.fullname" . -}}
{{- $kafkaBrokers := include "posthog.kafka.brokers" . -}}
{{- $chHost := include "posthog.clickhouse.host" . -}}
{{- $redisUrl := include "posthog.redis.url" . -}}
{{- $siteUrl := required "siteUrl is required" .Values.siteUrl -}}
# Django / PostHog
- name: SITE_URL
  value: {{ $siteUrl | quote }}
- name: DEPLOYMENT
  value: {{ .Values.deployment | quote }}
- name: IS_BEHIND_PROXY
  value: {{ .Values.isBehindProxy | quote }}
{{- if .Values.disabledSelfSignUp }}
- name: DISABLE_SIGNUP
  value: "true"
{{- end }}
{{- if .Values.allowedIpBlocks }}
- name: ALLOWED_IP_BLOCKS
  value: {{ .Values.allowedIpBlocks | quote }}
{{- end }}
{{- if .Values.trustAllProxies }}
- name: TRUST_ALL_PROXIES
  value: "true"
{{- end }}
- name: OPT_OUT_CAPTURE
  value: {{ .Values.optOutCapture | quote }}
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secretKey.existingSecret | required "secretKey.existingSecret is required" | quote }}
      key: {{ .Values.secretKey.key | quote }}
{{- if .Values.encryptionSaltKeys.existingSecret }}
- name: ENCRYPTION_SALT_KEYS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.encryptionSaltKeys.existingSecret | quote }}
      key: {{ .Values.encryptionSaltKeys.key | quote }}
{{- end }}
{{- if .Values.internalApiSecret.existingSecret }}
- name: INTERNAL_API_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalApiSecret.existingSecret | quote }}
      key: {{ .Values.internalApiSecret.key | quote }}
{{- else }}
- name: INTERNAL_API_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secretKey.existingSecret | quote }}
      key: {{ .Values.secretKey.key | quote }}
{{- end }}
{{- if .Values.internalRequestToken.existingSecret }}
- name: INTERNAL_REQUEST_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalRequestToken.existingSecret | quote }}
      key: {{ .Values.internalRequestToken.key | quote }}
{{- end }}
# Email
{{- if .Values.email.enabled }}
- name: EMAIL_HOST
  value: {{ .Values.email.host | quote }}
- name: EMAIL_PORT
  value: {{ .Values.email.port | quote }}
- name: EMAIL_HOST_USER
  value: {{ .Values.email.user | quote }}
- name: EMAIL_HOST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.email.password.existingSecret | required "email.password.existingSecret is required" | quote }}
      key: {{ .Values.email.password.key | quote }}
- name: EMAIL_USE_TLS
  value: {{ .Values.email.useTls | quote }}
- name: DEFAULT_FROM_EMAIL
  value: {{ .Values.email.fromEmail | quote }}
{{- end }}
# PostgreSQL
- name: DATABASE_URL
  {{- include "posthog.databaseUrl" . | nindent 2 }}
# This chart keeps persons in the main database, matching the Hobby deployment.
- name: PERSONS_DB_WRITER_URL
  {{- include "posthog.databaseUrl" . | nindent 2 }}
- name: PERSONS_DB_READER_URL
  {{- include "posthog.databaseUrl" . | nindent 2 }}
- name: PERSONS_DATABASE_URL
  {{- include "posthog.databaseUrl" . | nindent 2 }}
- name: BEHAVIORAL_COHORTS_DATABASE_URL
  {{- include "posthog.databaseUrl" . | nindent 2 }}
# ClickHouse
- name: CLICKHOUSE_HOST
  value: {{ $chHost | quote }}
- name: CLICKHOUSE_DATABASE
  value: {{ .Values.externalClickhouse.database | default "posthog" | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.externalClickhouse.user | quote }}
{{- if .Values.externalClickhouse.password.existingSecret }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalClickhouse.password.existingSecret | quote }}
      key: {{ .Values.externalClickhouse.password.key | quote }}
{{- end }}
- name: CLICKHOUSE_SECURE
  value: {{ .Values.externalClickhouse.secure | default false | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.externalClickhouse.verify | default false | quote }}
{{- $kafkaUrl := include "posthog.kafka.url" . }}
# Kafka / Redpanda
- name: KAFKA_URL
  value: {{ $kafkaUrl | quote }}
- name: KAFKA_HOSTS
  value: {{ $kafkaBrokers | quote }}
# Named Node.js producer slots do not inherit KAFKA_HOSTS.
- name: KAFKA_WARPSTREAM_INGESTION_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_WARPSTREAM_CYCLOTRON_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_WAREHOUSE_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_INGESTION_UPSTREAM_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_INGESTION_DOWNSTREAM_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
{{- if .Values.externalKafka.enabled }}
- name: KAFKA_SECURITY_PROTOCOL
  value: {{ .Values.externalKafka.securityProtocol | quote }}
- name: KAFKA_SASL_MECHANISM
  value: {{ .Values.externalKafka.saslMechanism | quote }}
{{- if .Values.externalKafka.saslUsername }}
- name: KAFKA_SASL_USER
  value: {{ .Values.externalKafka.saslUsername | quote }}
{{- end }}
{{- if .Values.externalKafka.saslPassword.existingSecret }}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.saslPassword.existingSecret | quote }}
      key: {{ .Values.externalKafka.saslPassword.key | quote }}
{{- end }}
{{- end }}
# Redis
- name: REDIS_URL
  value: {{ $redisUrl | quote }}
# Override the Kubernetes service-link variable, which contains a URL rather than a port number.
- name: POSTHOG_REDIS_PORT
  value: {{ .Values.redis.service.port | quote }}
- name: CDP_REDIS_HOST
  value: {{ printf "%s-redis" $fullname | quote }}
- name: CDP_REDIS_PORT
  value: "6379"
- name: LOGS_REDIS_HOST
  value: {{ printf "%s-redis" $fullname | quote }}
- name: LOGS_REDIS_PORT
  value: "6379"
- name: TRACES_REDIS_HOST
  value: {{ printf "%s-redis" $fullname | quote }}
- name: TRACES_REDIS_PORT
  value: "6379"
# Valkey
- name: CDP_VALKEY_HOST
  value: {{ printf "%s-valkey" $fullname | quote }}
- name: CDP_VALKEY_PORT
  value: "6379"
- name: COOKIELESS_REDIS_HOST
  value: {{ printf "%s-redis" $fullname | quote }}
- name: COOKIELESS_REDIS_PORT
  value: "6379"
# Object storage
- name: OBJECT_STORAGE_ENABLED
  value: "true"
- name: OBJECT_STORAGE_ENDPOINT
  value: {{ .Values.externalObjectStorage.endpoint | required "externalObjectStorage.endpoint is required" | quote }}
- name: OBJECT_STORAGE_PUBLIC_ENDPOINT
  value: {{ .Values.externalObjectStorage.publicEndpoint | default .Values.siteUrl | quote }}
- name: OBJECT_STORAGE_BUCKET
  value: {{ .Values.externalObjectStorage.bucket | quote }}
- name: OBJECT_STORAGE_REGION
  value: {{ .Values.externalObjectStorage.region | quote }}
{{- if .Values.externalObjectStorage.forcePathStyle }}
- name: OBJECT_STORAGE_FORCE_PATH_STYLE
  value: "true"
{{- end }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalObjectStorage.accessKey.existingSecret | required "externalObjectStorage.accessKey.existingSecret is required" | quote }}
      key: {{ .Values.externalObjectStorage.accessKey.key | quote }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalObjectStorage.secretKey.existingSecret | required "externalObjectStorage.secretKey.existingSecret is required" | quote }}
      key: {{ .Values.externalObjectStorage.secretKey.key | quote }}
# PersonHog
{{- if .Values.components.personhog.enabled }}
- name: PERSONHOG_ENABLED
  value: "true"
- name: PERSONHOG_ADDR
  value: {{ printf "%s-personhog-router:50052" $fullname | quote }}
- name: PERSON_TABLE
  value: "posthog_person"
- name: PERSON_DISTINCT_ID_TABLE
  value: "posthog_persondistinctid"
- name: FF_HASH_KEY_OVERRIDE_TABLE
  value: "posthog_featureflaghashkeyoverride"
- name: LIFECYCLE_OP_TABLE
  value: "lifecycle_op"
- name: LIFECYCLE_OP_PERSON_TABLE
  value: "lifecycle_op_person"
- name: PERSON_PUBLISH_OUTBOX_TABLE
  value: "person_publish_outbox"
{{- end }}
# Feature flags
- name: FEATURE_FLAGS_SERVICE_URL
  value: {{ printf "http://%s-feature-flags:3001" $fullname | quote }}
# Temporal
- name: TEMPORAL_HOST
  value: {{ printf "%s-temporal" $fullname | quote }}
- name: TEMPORAL_PORT
  value: "7233"
- name: TEMPORAL_USE_SINGLE_TASK_QUEUE
  value: "true"
# Browserless
{{- $browserlessSecret := .Values.browserless.token.existingSecret | default .Values.secretKey.existingSecret }}
{{- $browserlessKey := .Values.browserless.token.key | default .Values.secretKey.key }}
- name: BROWSERLESS_CDP_URL
  value: {{ printf "ws://%s-browserless:3000" $fullname | quote }}
- name: BROWSERLESS_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ $browserlessSecret | quote }}
      key: {{ $browserlessKey | quote }}
- name: HEATMAP_BROWSERLESS_URL
  value: {{ printf "http://%s-browserless:3000" $fullname | quote }}
- name: HEATMAP_BROWSERLESS_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ $browserlessSecret | quote }}
      key: {{ $browserlessKey | quote }}
# Logging / OTel
- name: OTEL_SDK_DISABLED
  value: "true"
# Livestream link shown in UI
- name: LIVESTREAM_HOST
  value: {{ printf "%s/livestream" $siteUrl | quote }}
{{- with .Values.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- /* Environment required only by the Node.js deployments. */ -}}
{{- define "posthog.nodeEnv" -}}
{{- $kafkaBrokers := include "posthog.kafka.brokers" . -}}
- name: CYCLOTRON_NODE_DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cyclotronDatabaseUrl.existingSecret | required "cyclotronDatabaseUrl.existingSecret is required for Node.js workloads" | quote }}
      key: {{ .Values.cyclotronDatabaseUrl.key | quote }}
- name: KAFKA_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_CDP_PRODUCER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
- name: KAFKA_CONSUMER_METADATA_BROKER_LIST
  value: {{ $kafkaBrokers | quote }}
{{- end }}

{{- /*
Node.js pg v8 treats sslmode=require as certificate verification. Preserve libpq
semantics for the internal PostgreSQL service without changing Django's URL.
The effective image command and arguments are passed as positional parameters.
*/ -}}
{{- define "posthog.nodeLibpqCommand" -}}
- sh
- -c
- |
  append_libpq_compat() {
    case "$1" in
      *\?*) printf '%s&uselibpqcompat=true' "$1" ;;
      *) printf '%s?uselibpqcompat=true' "$1" ;;
    esac
  }
  DATABASE_URL=$(append_libpq_compat "$DATABASE_URL")
  PERSONS_DB_WRITER_URL=$(append_libpq_compat "$PERSONS_DB_WRITER_URL")
  PERSONS_DB_READER_URL=$(append_libpq_compat "$PERSONS_DB_READER_URL")
  PERSONS_DATABASE_URL=$(append_libpq_compat "$PERSONS_DATABASE_URL")
  BEHAVIORAL_COHORTS_DATABASE_URL=$(append_libpq_compat "$BEHAVIORAL_COHORTS_DATABASE_URL")
  export DATABASE_URL PERSONS_DB_WRITER_URL PERSONS_DB_READER_URL PERSONS_DATABASE_URL BEHAVIORAL_COHORTS_DATABASE_URL
  if [ -n "${CYCLOTRON_NODE_DATABASE_URL:-}" ]; then
    CYCLOTRON_NODE_DATABASE_URL=$(append_libpq_compat "$CYCLOTRON_NODE_DATABASE_URL")
    export CYCLOTRON_NODE_DATABASE_URL
  fi
  exec "$@"
{{- end }}
