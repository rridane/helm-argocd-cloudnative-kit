{{- define "cloudnative.ephemeral_volume_source" }}
    volumeClaimTemplate:
      spec:
        accessModes:
          {{- range .volumeClaimTemplate.spec.accessModes }}
          - {{ . | quote }}
          {{- end }}
        {{- with .volumeClaimTemplate.spec.storageClassName }}
        storageClassName: {{ . | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ .volumeClaimTemplate.spec.resources.requests.storage | quote }}
{{- end }}