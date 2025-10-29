# 🧩 otel-collector-generator

> **Générateur modulaire d’OpenTelemetry Collector ConfigMap à partir de fragments YAML**  
> Simplifiez, structurez et versionnez vos configurations OpenTelemetry Collector sans jamais écrire de YAML monolithique.

---

## 🌟 Introduction

`otel-collector-generator` est un **chart Helm intelligent** qui assemble dynamiquement la configuration d’un **OpenTelemetry Collector** à partir de fragments YAML indépendants regroupés par rôle (`receivers`, `processors`, `exporters`, `connectors`, `pipelines`).

Cette approche permet de **décomposer, fusionner et réutiliser** les configurations OTel de manière **lisible, maintenable et portable**, tout en générant automatiquement un `ConfigMap` complet et valide pour votre collector.

---

## 🧱 Architecture

Le chart repose sur une logique simple et élégante :

```
📂 files/
 └─ default/
     ├─ receivers/
     │   ├─ otlp.yaml
     │   └─ k8s_events.yaml
     ├─ processors/
     │   ├─ batch.yaml
     │   ├─ memory_limiter.yaml
     │   ├─ transform.yaml
     │   └─ tail_sampling.yaml
     ├─ exporters/
     │   ├─ clickhouse.yaml
     │   ├─ loki.yaml
     │   ├─ otlp.yaml
     │   └─ prometheus.yaml
     ├─ connectors/
     │   └─ spanmetrics.yaml
     └─ pipelines.yaml
```

🧩 Chaque dossier contient des fragments YAML correspondant à sa catégorie (receiver, processor, etc.).  
Le chart fusionne automatiquement tous les fichiers détectés, puis assemble la configuration complète du Collector.

---

## ⚙️ Fonctionnement interne

Le `ConfigMap` est généré via un template Helm utilisant la fonction `merge` :

```gotmpl
{{- range $kind, $path := $dirs }}
  {{- range $file, $_ := ($.Files.Glob (printf "%s/*.y*ml" $path)) }}
    {{- $yaml := fromYaml ($.Files.Get $file) }}
    {{- $kindConf := (get $conf $kind) }}
    {{- $newConf := (merge $kindConf $yaml) }}
    {{- $_ := set $conf $kind $newConf }}
  {{- end }}
{{- end }}

{{- $pipelines := fromYaml ($.Files.Get .Values.pipelinesFile) }}

{{- $otelConfig := dict
  "receivers"  (get $conf "receivers")
  "processors" (get $conf "processors")
  "exporters"  (get $conf "exporters")
  "connectors" (get $conf "connectors")
  "service"    $pipelines
-}}
```

Ce mécanisme :
- Fusionne récursivement tous les fichiers YAML par type.
- Charge un unique `pipelines.yaml` (plus lisible qu’un ensemble de fragments).
- Produit un `config.yaml` final cohérent, injecté dans la ConfigMap `otel-configmap`.

---

## 🧩 Exemple de ConfigMap généré

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-configmap
  namespace: observability
data:
  config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            max_recv_msg_size_mib: 100
    processors:
      batch:
        timeout: 15s
    exporters:
      loki:
        endpoint: http://loki.loki.svc:3100/loki/api/v1/push
    service:
      pipelines:
        logs:
          receivers: [otlp]
          processors: [batch]
          exporters: [loki]
```

---

## 🚀 Installation

### 1️⃣ Ajouter le chart à votre dépôt local

```bash
helm repo add my-charts https://<votre-repo-helm>
helm repo update
```

### 2️⃣ Installer le chart

```bash
helm install otel ./otel-collector-generator \
  --namespace observability \
  --create-namespace
```

---

## 🧠 Paramètres disponibles (`values.yaml`)

| Clé | Type | Description | Valeur par défaut |
|------|------|--------------|-------------------|
| `namespace` | string | Namespace Kubernetes | `observability` |
| `name` | string | Nom de la ressource | `invoiced` |
| `replicas` | int | Nombre de replicas | `3` |
| `serviceAccountName` | string | ServiceAccount utilisé | `otelcontribcol` |
| `image` | string | Image collector utilisée | `otel/opentelemetry-collector-contrib:0.81.0` |
| `featureGates` | list | Feature gates activés | `["--feature-gates=filelog.allowHeaderMetadataParsing"]` |
| `resources` | map | Limites CPU/Mémoire | Voir fichier par défaut |
| `receiversDir` | string | Dossier des receivers | `files/default/receivers` |
| `processorsDir` | string | Dossier des processors | `files/default/processors` |
| `exportersDir` | string | Dossier des exporters | `files/default/exporters` |
| `connectorsDir` | string | Dossier des connectors | `files/default/connectors` |
| `pipelinesFile` | string | Fichier unique de pipelines | `files/default/pipelines.yaml` |

---

## 🧩 Personnalisation

Vous pouvez facilement créer plusieurs variantes :

### ➤ Exemple : environnement staging

```
files/
 └─ staging/
     ├─ receivers/
     ├─ processors/
     ├─ exporters/
     ├─ connectors/
     └─ pipelines.yaml
```

Puis dans vos valeurs :
```yaml
receiversDir: "files/staging/receivers"
processorsDir: "files/staging/processors"
exportersDir: "files/staging/exporters"
connectorsDir: "files/staging/connectors"
pipelinesFile: "files/staging/pipelines.yaml"
```

---

## 🧰 Intégration GitOps

Ce chart est parfaitement compatible avec **ArgoCD**, **FluxCD** ou tout autre outil GitOps.  
Chaque commit sur les fragments YAML régénère dynamiquement la configuration complète du collector sans avoir à éditer un monolithe YAML.

---

## 🧪 Validation locale

Pour vérifier la configuration avant déploiement :

```bash
helm template otel ./otel-collector-generator > rendered.yaml
yq '.data["config.yaml"]' rendered.yaml > /tmp/config.yaml

docker run --rm -v /tmp/config.yaml:/etc/config.yaml \
  otel/opentelemetry-collector-contrib:0.81.0 \
  --config=/etc/config.yaml --dry-run
```

---

## 🧠 Avantages clés

✅ **Modularité totale** : chaque receiver, processor ou exporter est indépendant.  
✅ **Clarté** : fini les YAML monolithiques illisibles.  
✅ **Réutilisabilité** : fragments partageables entre environnements et projets.  
✅ **Maintenance aisée** : les ajouts et suppressions ne cassent pas la structure globale.  
✅ **Compatibilité OpenTelemetry** : produit un `config.yaml` standard, reconnu nativement.

---

## 🧩 Exemple d’intégration complète

```bash
helm upgrade --install otel ./otel-collector-generator \
  --set namespace=observability \
  --set name=myapp \
  --set image=otel/opentelemetry-collector-contrib:0.83.0 \
  --set receiversDir=files/prod/receivers \
  --set pipelinesFile=files/prod/pipelines.yaml
```

---

## 🪄 Auteur

Conçu par [**Rida Ridane**](https://github.com/rridane) — CTO Platform & Software Engineering Lead,  
passionné d’**observabilité**, **Kubernetes**, **Helm**, et **architecture cloud-native**.

---

## 📄 Licence

Ce chart est distribué sous licence **Apache 2.0**.  
Vous êtes libre de le modifier, redistribuer et intégrer dans vos pipelines GitOps.

---

## 🧠 Inspirations

- OpenTelemetry Helm Charts – opentelemetry-helm-charts  
- Helm Docs – merge / dict functions  
- CueLang & Jsonnet pour la logique déclarative  
- ArgoCD ConfigMap Generator Pattern

---

## 🧩 TL;DR

> Ce chart transforme la configuration OpenTelemetry Collector en **infrastructure composable et maintenable**.  
>
> **Plus besoin d’un `config.yaml` monstre.**  
>
> Chaque bloc devient un module réutilisable, versionné et fusionné automatiquement.

---

🧠 _“Structure brings clarity. Clarity brings reliability.”_ — *Otel Collector Generator*
