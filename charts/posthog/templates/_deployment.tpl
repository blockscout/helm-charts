{{- /*
Generic Deployment template.
Usage: {{ include "posthog.deployment" (dict "root" . "name" "web" "component" .Values.components.web "valuesKey" "web") }}
*/ -}}
{{- define "posthog.deployment" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $component := .component -}}
{{- $valuesKey := .valuesKey -}}
{{- $fullName := include "posthog.fullname" $root -}}
{{- if $component.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $fullName }}-{{ $name }}
  labels:
    {{- include "posthog.componentLabels" (dict "root" $root "component" $name) | nindent 4 }}
spec:
  replicas: {{ $component.replicaCount }}
  {{- if $component.deploymentStrategy }}
  strategy:
    {{- toYaml $component.deploymentStrategy | nindent 4 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "posthog.componentSelectorLabels" (dict "root" $root "component" $name) | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "posthog.componentSelectorLabels" (dict "root" $root "component" $name) | nindent 8 }}
      {{- with $root.Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      {{- with $root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "posthog.serviceAccountName" $root }}
      securityContext:
        {{- toYaml $root.Values.podSecurityContext | nindent 8 }}
      {{- with $component.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $name }}
          image: {{ include "posthog.image" (list $root $component.image) | quote }}
          imagePullPolicy: {{ $component.image.pullPolicy }}
          {{- if $component.nodeLibpqCompat }}
          command:
            {{- include "posthog.nodeLibpqCommand" $root | nindent 12 }}
          args:
            - "--"
            {{- if $component.command }}
            {{- toYaml $component.command | nindent 12 }}
            {{- else }}
            - node
            - nodejs/dist/index.js
            {{- end }}
            {{- with $component.args }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- else }}
          {{- with $component.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $component.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
          securityContext:
            {{- toYaml $root.Values.containerSecurityContext | nindent 12 }}
          {{- if $component.service }}
          ports:
            - name: http
              containerPort: {{ $component.service.port }}
              protocol: TCP
          {{- end }}
          env:
            {{- include "posthog.commonEnv" $root | nindent 12 }}
            {{- if $component.cdpApiClient }}
            - name: CDP_API_URL
              value: {{ printf "http://%s-plugins:6738" $fullName | quote }}
            {{- end }}
            {{- if $component.nodeLibpqCompat }}
            {{- include "posthog.nodeEnv" $root | nindent 12 }}
            {{- end }}
            {{- with $component.env }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- if $component.livenessProbe }}
          livenessProbe:
            {{- toYaml $component.livenessProbe | nindent 12 }}
          {{- end }}
          {{- if $component.readinessProbe }}
          readinessProbe:
            {{- toYaml $component.readinessProbe | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml $component.resources | nindent 12 }}
          {{- with $component.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with $component.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $component.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- else }}
      {{- with $root.Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- with $component.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- else }}
      {{- with $root.Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- with $component.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- else }}
      {{- with $root.Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- with $component.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- else }}
      {{- with $root.Values.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
{{- end }}
{{- end }}
