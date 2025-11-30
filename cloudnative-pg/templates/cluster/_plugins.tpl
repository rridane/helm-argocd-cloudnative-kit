{{- define "cloudnative.plugins" -}}
{{- range . -}}
- name: {{ .name | quote }}
  {{- with .isWALArchiver }}
  isWALArchiver: {{ . }}
  {{- end }}
  {{- with .parameters }}
  parameters:
    {{ toYaml . }}
  {{- end }}
{{- end }}
{{- end }}