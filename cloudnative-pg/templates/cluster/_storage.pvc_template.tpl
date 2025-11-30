{{- define "cloudnative.storage.pvc_template" }}
      accessModes:
        {{- range .accessModes }}
        - {{ . }}
        {{- end }}
      resources:
        requests:
          storage: {{ .resources.requests.storage }}
      storageClassName: {{ .storageClassName }}
      volumeMode: {{ .volumeMode | default "Filesystem" }}
{{- end }}