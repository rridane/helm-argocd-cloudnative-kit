{{- define "cloudnative.bootstrap.recovery" }}
{{- with .recovery -}}
recovery:
{{- with .source }}
source: {{ . | quote }}
{{- end }}

{{- with .backup }}
backup:
  name: {{ .name | quote }}
{{- end }}

{{- with .recoveryTarget }}
recoveryTarget:
  {{- with .targetTime }}
  targetTime: {{ . | quote }}
  {{- end }}
{{- end }}

{{- with .database }}
database: {{ . | quote }}
{{- end }}
{{- with .owner }}
owner: {{ . | quote }}
{{- end }}
{{- with .secret }}
secret:
  name: {{ .name | quote }}
{{- end }}
{{- end }}
{{- end }}