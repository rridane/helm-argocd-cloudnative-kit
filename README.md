# helm-argocd-cloudnative-kit

A small library of Helm charts I wrote for running cloud-native platforms with
ArgoCD. Each one is a "generator" chart: you describe what you want in a compact
`values.yaml`, and the chart renders the Kubernetes objects — so the platform
stays declarative and GitOps-friendly, without hand-writing raw manifests.

## The charts

| Chart | What it does |
|-------|--------------|
| `cloudnative-pg` | A CloudNativePG database from values — Cluster, pgbouncer Pooler, Barman-cloud backup to S3, ImageCatalog, scheduled backups. |
| `gateway-http-routes` | Traefik Gateway-API `HTTPRoute`s and `Middleware`s from a simple list of applications + routes. |
| `opentelemetry` | A multi-role OpenTelemetry Collector (gateway / agent DaemonSet / scraper) assembled from modular receiver/processor/exporter/pipeline fragments. |
| `parca` | Parca server + agent for continuous profiling. |
| `pvc-generator` | `PersistentVolumeClaim`s generated from a declarative list — handy in GitOps flows. |
| `rancher-rbac` | Declarative Rancher RBAC (GlobalRoles, RoleTemplates, bindings, Projects) from a cluster list + a Keycloak-group → role mapping. |
| `filebrowser` | Filebrowser with backing storage. |

## Using them

The charts are published as **OCI artifacts** on GitHub Container Registry:

    helm install pg oci://ghcr.io/rridane/charts/cloudnative-pg --version 0.1.0 -f values.yaml

Or from ArgoCD, as a normal Helm source (`repoURL: ghcr.io/rridane/charts`,
`chart: <name>`, values in your own repo).

## Publishing

`.github/workflows/release-charts.yml` packages every chart and pushes it to
`oci://ghcr.io/rridane/charts` on a `v*` tag. Bump a chart's `version` to cut a
new release.

## License

MIT.
