{{- define  "cloudnative.image_catalog_ref" -}}
kind: {{ .kind }}
apiGroup: {{ .apiGroup }}
name: {{ .name }}
major: {{ .major }}
{{- with .namespace }}
namespace: {{ . }}
{{- end }}
{{- end }}