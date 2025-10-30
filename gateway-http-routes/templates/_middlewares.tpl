{{- define "process_middlewares" -}}
{{- $namespace := .namespace }}
{{- $route := .route }}
{{- range $index, $mw := $route.middlewares }}
{{- if eq $mw.type "strip-prefix" }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
    name: {{ printf "%s-strip-prefix-%d" $route.name $index }}
    namespace: {{ $namespace }}
spec:
    stripPrefix:
        prefixes:
            - {{ $mw.prefix }}
{{- end }}

{{- if eq $mw.type "add-prefix" }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
    name: {{ printf "%s-add-prefix-%d" $route.name $index }}
    namespace: {{ $namespace }}
spec:
    addPrefix:
        prefix: {{ $mw.prefix }}
{{- end }}

{{- if eq $mw.type "override-headers" }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
    name: {{ printf "%s-override-header-%d" $route.name $index }}
    namespace: {{ $namespace }}
spec:
    headers:
        customRequestHeaders:
            {{ $mw.key }}: {{ $mw.value }}
{{- end }}
{{- end }}
{{- end }}
