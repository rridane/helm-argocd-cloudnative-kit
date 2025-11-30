{{- define "cloudnative.tablespaces" }}
    {{- range . }}
    - name: {{ .name | quote }}
      {{- with .owner }}
      owner:
        name: {{ .name | quote }}
      {{- end }}
      {{- with .temporary }}
      temporary: {{ . }}
      {{- end }}
      storage:
        size: {{ .storage.size | quote }}
        {{- with .storage.storageClass }}
        storageClass: {{ . | quote }}
        {{- end }}
    {{- end }}
{{- end }}