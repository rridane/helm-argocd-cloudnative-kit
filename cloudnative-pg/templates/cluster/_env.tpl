{{- define "cloudnative.env"}}
  {{- with .Values.env }}
  env:
    {{- range . }}
    - name: {{ .name }}
      value: {{ .value | quote }}
    {{- end }}
  {{- end }}
  {{- with .Values.envFrom }}
  envFrom:
    {{- range . }}
    {{- if .configMapRef }}
    - configMapRef:
        name: {{ .configMapRef.name }}
    {{- end }}
    {{- if .secretRef }}
    - secretRef:
        name: {{ .secretRef.name }}
    {{- end }}
    {{- end }}
  {{- end }}
{{- end }}