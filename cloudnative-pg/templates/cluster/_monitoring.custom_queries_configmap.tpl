{{- define "cloudnative.monitoring.custom_queries_configmap" }}
  {{- $list := list }}

  {{- if .Values.customQueriesConfigMap }}
    {{- $defaultConfigMap := dict "name" .Values.customQueriesConfigMap.name "key" .Values.customQueriesConfigMap.key }}
    {{- $list = append $list $defaultConfigMap }}
  {{- end }}

  {{- range .Values.monitoring.additionalCustomQueriesConfigMap }}
    {{- $list = append $list . }}
  {{- end }}

  {{- if gt (len $list) 0 }}
customQueriesConfigMap:
    {{- range $list }}
  - name: {{ .name }}
    key: {{ .key }}
    {{- end }}
  {{- end }}
{{- end }}