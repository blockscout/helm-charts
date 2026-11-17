{{- /*
Generic Service template.
Usage: {{ include "posthog.service" (dict "root" . "name" "redis" "port" .Values.redis.service.port "extraPorts" (list ...)) }}
*/ -}}
{{- define "posthog.service" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $port := .port -}}
{{- $fullName := include "posthog.fullname" $root -}}
{{- if .enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $fullName }}-{{ $name }}
  labels:
    {{- include "posthog.componentLabels" (dict "root" $root "component" $name) | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    - port: {{ $port }}
      targetPort: http
      protocol: TCP
      name: http
    {{- with .extraPorts }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  selector:
    {{- include "posthog.componentSelectorLabels" (dict "root" $root "component" $name) | nindent 4 }}
{{- end }}
{{- end }}
