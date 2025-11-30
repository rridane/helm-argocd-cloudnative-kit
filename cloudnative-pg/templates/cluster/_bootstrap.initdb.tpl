{{- define "cloudnative.boostrap.initdb" }}
{{- with .initdb -}}
initdb:
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

  {{- with .import }}
  import:
    type: {{ .type | quote }}
    {{- with .databases }}
    databases:
      {{- range . }} - {{ . | quote }} {{- end }}
    {{- end }}
    {{- with .roles }}
    roles:
      {{- range . }} - {{ . | quote }} {{- end }}
    {{- end }}
    {{- with .pgDumpExtraOptions }}
    pgDumpExtraOptions:
      {{- range . }} - {{ . | quote }} {{- end }}
    {{- end }}
    {{- with .pgRestoreExtraOptions }}
    pgRestoreExtraOptions:
      {{- range . }} - {{ . | quote }} {{- end }}
    {{- end }}
    {{- with .source }}
    source:
      externalCluster: {{ .externalCluster | quote }}
    {{- end }}
  {{- end }}

  {{- with .dataChecksums }}
  dataChecksums: {{ . }}
  {{- end }}
  {{- with .encoding }}
  encoding: {{ . | quote }}
  {{- end }}
  {{- with .locale }}
  locale: {{ . | quote }}
  {{- end }}
  {{- with .localeCollate }}
  localeCollate: {{ . | quote }}
  {{- end }}
  {{- with .localeCType }}
  localeCType: {{ . | quote }}
  {{- end }}
  {{- with .localeProvider }}
  localeProvider: {{ . | quote }}
  {{- end }}
  {{- with .icuLocale }}
  icuLocale: {{ . | quote }}
  {{- end }}
  {{- with .icuRules }}
  icuRules: {{ . | quote }}
  {{- end }}
  {{- with .walSegmentSize }}
  walSegmentSize: {{ . }}
  {{- end }}

  {{- with .postInitSQL }}
  postInitSQL:
    {{- range . }}
    - |
      {{ . | nindent 8 }}
    {{- end }}
  {{- end }}

  {{- with .postInitApplicationSQLRefs }}
  postInitApplicationSQLRefs:
    {{- with .secretRefs }}
    secretRefs:
      {{- range . }}
      - name: {{ .name }}
        key: {{ .key }}
      {{- end }}
    {{- end }}
    {{- with .configMapRefs }}
    configMapRefs:
      {{- range . }}
      - name: {{ .name }}
        key: {{ .key }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}