{{- define "cloudnative.labels" }}
    {{- with .Values.labels }}
    {{- toYaml . }}
    {{- end }}
{{- end }}