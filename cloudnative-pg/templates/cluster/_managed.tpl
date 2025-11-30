{{- define "cloudnative.managed" -}}
roles:
  {{- range . }}
  - name: {{ .name }}
    ensure: {{ .ensure | default "present" | quote }}
    {{- with .login }}
    login: {{ . }}
    {{- end }}
    {{- with .comment }}
    comment: {{ . | quote }}
    {{- end }}
    {{- with .superuser }}
    superuser: {{ . }}
    {{- end }}

    {{- with .passwordSecret }}
    passwordSecret:
      name: {{ .name }}
    {{- end }}

    {{- with .inRoles }}
    inRoles:
      {{- range . }}
      - {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}