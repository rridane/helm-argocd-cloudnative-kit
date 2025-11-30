{{- define "cloudnative.boostrap.pg_basebackup" }}
{{- with .pg_basebackup -}}
pg_basebackup:
  source: {{ .source | quote }}
{{- end }}
{{- end }}  # end bootstrap