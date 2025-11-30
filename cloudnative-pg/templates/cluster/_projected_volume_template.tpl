{{- define "cloudnative.projected_volume_template" }}
    sources:
      {{- range .sources }}
      {{- if .secret }}
      - secret:
          name: {{ .secret.name | quote }}
          items:
            {{- range .secret.items }}
            - key: {{ .key | quote }}
              path: {{ .path | quote }}
            {{- end }}
      {{- end }}
      {{- end }}
{{- end }}