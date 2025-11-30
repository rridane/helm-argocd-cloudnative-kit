{{- define "cloudnative.annotations" -}}
    {{- with .Values.annotations }}
    {{- toYaml . }}
    {{- end }}
    {{- with .Values.fenceInstances }}
    {{- if gt (len .) 0 }}
    cnpg.io/fencedInstances: '{{ . }}'
    {{- end }}
    {{- end }}
{{- end}}