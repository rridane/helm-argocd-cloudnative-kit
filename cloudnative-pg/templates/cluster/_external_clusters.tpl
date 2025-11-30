{{- define "cloudnative.external_clusters" -}}
    {{- range . }}
    - name: {{ .name }}
      {{- if and .plugin (eq .plugin.name "barman-cloud.cloudnative-pg.io") }}
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: {{ .plugin.parameters.barmanObjectName | quote }}
          serverName: {{ .plugin.parameters.serverName | quote }}
      {{- else if .connectionParameters }}
      connectionParameters:
        host: {{ .connectionParameters.host | quote }}
        user: {{ .connectionParameters.user | quote }}
      {{- with .password -}}
      password:
        name: {{ .name }}
        key: {{ .key }}
      {{- end }}
      {{- else }}
      {{- fail (printf "externalCluster '%s' must define either plugin=barman-cloud.cloudnative-pg.io or connectionParameters" .name) }}
      {{- end }}
    {{- end }}
  {{- end }}