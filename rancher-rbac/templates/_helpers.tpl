{{/*
Backing namespace d'un Project Rancher : <cluster-id>-<project-name>.
*/}}
{{- define "rancher-rbac.projectBackingNs" -}}
{{- printf "%s-%s" .clusterId .projectName -}}
{{- end -}}

{{/*
Représentation Rancher d'un groupe Keycloak.
*/}}
{{- define "rancher-rbac.keycloakGroupPrincipal" -}}
{{- printf "keycloakoidc_group://%s" . -}}
{{- end -}}
