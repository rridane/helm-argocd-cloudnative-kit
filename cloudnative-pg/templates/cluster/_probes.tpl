{{- define "cloudnative.probes" -}}
{{- with .startup }}
{{- if .enabled }}
startup:
  periodSeconds: {{ .periodSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
  failureThreshold: {{ .failureThreshold }}
  {{- if eq .type "streaming" }}
  type: streaming
  maximumLag: {{ .maximumLag }}
  {{- else if eq .type "query" }}
  type: query
  {{- else if eq .type "pg_isready" }}
  type: pg_isready
  {{- else }}
  {{- fail (printf "Invalid probes.startup.type: '%s'" .type) }}
  {{- end }}
{{- end }}
{{- end }}

{{- with .liveness }}
{{- if .enabled }}
liveness:
  periodSeconds: {{ .periodSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
  failureThreshold: {{ .failureThreshold }}
  {{- with .isolationCheck }}
  isolationCheck:
    enabled: {{ .enabled }}
    requestTimeout: "{{ .requestTimeout }}"
    connectionTimeout: "{{ .connectionTimeout }}"
  {{- end }}
{{- end }}
{{- end }}

{{- with .readiness }}
{{- if .enabled }}
readiness:
  periodSeconds: {{ .periodSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
  failureThreshold: {{ .failureThreshold }}
  {{- if eq .type "streaming" }}
  type: streaming
  maximumLag: {{ .maximumLag }}
  {{- else if eq .type "query" }}
  type: query
  {{- else if eq .type "pg_isready" }}
  type: pg_isready
  {{- else }}
  {{- fail (printf "Invalid probes.readiness.type: '%s'" .type) }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}