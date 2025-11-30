{{- define "cloudnative.postgresql_conf" }}

{{- with .parameters }}
parameters:
  {{- range $key, $value := . }}
  {{- if kindIs "string" $value }}
  {{ $key }}: {{ $value | quote }}
  {{- else }}
  {{- /* erreur claire : render un commentaire pour le dev */}}
  {{- printf "# ERROR: parameter '%s' must be a string, but got %s" $key (kindOf $value) | nindent 2 }}
  {{- end }}
  {{- end }}
{{- end }}

{{- with .pg_hba }}
pg_hba:
  {{- range . }}
  - {{ . }}
  {{- end }}
{{- end }}

{{- with .pg_ident }}
pg_ident:
  {{- range . }}
  - {{ . }}
  {{- end }}
{{- end }}

{{- with .shared_preload_libraries }}
shared_preload_libraries:
  {{- range . }}
  - {{ . | quote }}
  {{- end }}
{{- end }}

{{- with .synchronous }}
synchronous:
  {{- with .method }}
  method: {{ . | quote }}
  {{- end }}
  {{- with .number }}
  number: {{ . }}
  {{- end }}
  {{- with .maxStandbyNamesFromCluster }}
  maxStandbyNamesFromCluster: {{ . }}
  {{- end }}
  {{- with .standbyNamesPre }}
  standbyNamesPre:
    {{- range . }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- with .standbyNamesPost }}
  standbyNamesPost:
    {{- range . }}
    - {{ . | quote }}
    {{- end }}
  {{- end }}
  {{- with .dataDurability }}
  dataDurability: {{ . | quote }}
  {{- end }}
{{- end }}

{{- with .extensions }}
extensions:
  {{- range . }}
  - name: {{ .name | quote }}
    {{- with .ld_library_path }}
    ld_library_path:
      {{- range . }}
      - {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- with .image }}
    image:
      {{- with .reference }}
      reference: {{ . | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}