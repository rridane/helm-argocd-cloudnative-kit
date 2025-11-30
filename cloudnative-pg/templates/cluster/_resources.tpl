{{- define "cloudnative.resources" -}}
{{- with .requests -}}
requests:
    {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .limits }}
limits:
    {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}