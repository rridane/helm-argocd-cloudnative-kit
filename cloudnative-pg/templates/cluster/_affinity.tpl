{{- define "cloudnative.affinity" }}
    {{- with .nodeSelector }}
    nodeSelector:
      {{- toYaml . | nindent 6 }}
    {{- end }}
{{- end }}