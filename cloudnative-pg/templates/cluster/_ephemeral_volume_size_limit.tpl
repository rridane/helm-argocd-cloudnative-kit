{{- define "cloudnative.ephemeral_volume_size_limit" }}
    {{- with .shm }}
    shm: {{ . | quote }}
    {{- end }}
    {{- with .temporaryData }}
    temporaryData: {{ . | quote }}
    {{- end }}
{{- end }}