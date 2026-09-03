# otel-collector-generator

> **Framework Helm pour déployer un OpenTelemetry Collector multi-rôle à partir de fragments YAML modulaires.**

Ce chart n'embarque aucun fragment de configuration : il **assemble** dynamiquement un OpenTelemetry Collector à partir de fragments YAML que tu fournis (receivers, processors, exporters, connectors, pipelines). Il rend les 3 rôles canoniques OTel — `gateway`, `agent`, `scraper` — en filtrant chaque ConfigMap pour ne garder que les fragments réellement utilisés par les pipelines actives.

Le pattern est conçu pour le **multi-cluster** : un cluster central (mode `gateway` actif, exports vers les backends) + N clusters downstream (mode `gateway` désactivé, push OTLP vers le cluster central).

---

## Sommaire

1. [Les 3 rôles](#les-3-rôles)
2. [Pattern bridge](#pattern-bridge)
3. [Structure de répertoires attendue](#structure-de-répertoires-attendue)
4. [Référence des values](#référence-des-values)
5. [Pièges importants](#pièges-importants)
6. [Exemple complet](#exemple-complet)

---

## Les 3 rôles

```
                 ┌─────────────────────────────────────────────┐
                 │            CLUSTER (CENTRAL OU NON)         │
                 │                                              │
                 │   ┌─────────────┐       ┌─────────────────┐ │
                 │   │   AGENT     │       │   SCRAPER       │ │
                 │   │ DaemonSet   │       │ Deployment x1   │ │
                 │   │ par-node    │       │ singleton       │ │
                 │   │             │       │                 │ │
                 │   │ hostmetrics │       │ prometheus      │ │
                 │   │ kubeletstats│       │ k8s_cluster     │ │
                 │   │ filelog     │       │ k8s_events      │ │
                 │   └──────┬──────┘       └────────┬────────┘ │
                 │          │ OTLP (push)           │ OTLP    │
                 │          v                       v          │
                 │   ┌─────────────────────────────────────┐  │
                 │   │            GATEWAY                  │  │
                 │   │     Deployment N répliques          │  │
                 │   │     ingest passif OTLP              │  │
                 │   │  (apps instrumentées + agents)      │  │
                 │   └──────────────────┬──────────────────┘  │
                 │                      │                      │
                 └──────────────────────┼──────────────────────┘
                                        │
                                 vers backends
                              (Mimir, Loki, Tempo,
                            Pyroscope, autres OTLP)
```

| Rôle | Resource k8s | Replicas | Use case |
|---|---|---|---|
| **gateway** | Deployment | N (pour HA) | Receveur OTLP central. Ingère le trafic des agents et des apps instrumentées, route vers les backends. **N'embarque jamais de receiver actif** (sinon duplication N fois). |
| **agent** | DaemonSet | 1 par node | Scrape les sources **node-local** (hostmetrics, kubeletstats, filelog). Une instance par node = pas de duplication par construction. |
| **scraper** | Deployment | **1 (singleton obligatoire)** | Scrape les sources **cluster-wide** (prometheus pour kube-state-metrics, k8s_cluster, k8s_events). Singleton volontaire pour éviter la duplication des séries (cf. [doc OTel Scaling the Collector](https://opentelemetry.io/docs/collector/scaling/)). |

Sur le **cluster central**, les 3 sont actifs (gateway reçoit + exporte, agent + scraper poussent en interne vers la gateway locale).

Sur les **clusters downstream**, seuls `agent` et `scraper` sont actifs (push OTLP direct vers la gateway centrale).

---

## Pattern bridge

Le chart **ne contient pas la configuration** des fragments : tu la fournis depuis un dossier externe (un *bridge*) via un script `generate.sh` qui copie les fragments dans le chart juste avant `helm template`. Cette approche permet :

* de **versionner la conf séparément** du chart
* d'avoir **plusieurs variants** (adm + downstream + autres) avec un seul chart
* de **mutualiser** les fragments communs (receivers, processors)

Le bridge type ressemble à ça :

```text
my-otel-bridge/
├── generate.sh                       # rend le chart pour un variant donné
├── values-adm.yaml                   # values du variant central
├── values-downstream.yaml            # values du variant downstream
├── receivers/                        # COMMUN : 1 fichier par receiver
├── processors/                       # COMMUN : 1 fichier par processor
├── pipelines/                        # COMMUN au top, sous-dossier par variant
│   ├── adm/
│   │   ├── gateway.yaml
│   │   ├── agent.yaml
│   │   └── scraper.yaml
│   └── downstream/
│       ├── agent.yaml
│       └── scraper.yaml
└── per-cluster/                      # SPÉCIFIQUE : tout ce qui change par variant
    ├── adm/
    │   ├── connectors/
    │   └── exporters/                # exports vers backends
    └── downstream/
        └── exporters/                # export vers gateway centrale
```

* Tout ce qui est au **top niveau** (`receivers/`, `processors/`, `pipelines/`) est **commun aux variants** ou trié par variant via sous-dossier.
* Tout ce qui change par variant est sous **`per-cluster/<variant>/`**.

---

## Structure de répertoires attendue

Le chart cherche les fragments aux paths déclarés dans le values. Par défaut :

| Type | Path par défaut | Convention recommandée |
|---|---|---|
| Receivers | `receivers/` | top-level (commun aux variants) |
| Processors | `processors/` | top-level (commun aux variants) |
| Exporters | `per-cluster/<variant>/exporters/` | propre au variant (les backends diffèrent) |
| Connectors | `per-cluster/<variant>/connectors/` | propre au variant (souvent juste sur central) |
| Gateway pipelines | `pipelines/<variant>/gateway.yaml` | un fichier par rôle, par variant |
| Agent pipelines | `pipelines/<variant>/agent.yaml` | |
| Scraper pipelines | `pipelines/<variant>/scraper.yaml` | |

Tu peux remapper tous ces paths via les values. Pas obligé de suivre la convention si ton organisation diffère.

### Filtrage automatique

Le chart **lit chaque `<role>-pipelines` file**, en extrait la liste des receivers/processors/exporters/connectors **réellement référencés**, et **filtre** chaque ConfigMap pour ne garder que ces fragments. Tu peux donc avoir 50 fragments dans `receivers/` mais seuls ceux cités dans les pipelines apparaîtront dans le ConfigMap final.

### Overlay variant-specific

Pour chaque type de fragment (receivers/processors/exporters/connectors), le chart accepte un **dossier d'overlay optionnel** via `<kind>OverlayDir`. Quand un fragment du même nom existe dans le path principal ET dans l'overlay, **la version de l'overlay écrase**.

Cas d'usage : un processor commun aux variants (ex `processors/batch.yaml`) cohabite avec un processor variant-specific (ex `processors/resource_cluster.yaml` qui sette une valeur différente par cluster). Sans overlay, on devrait dupliquer tous les processors par variant.

Exemple values :

```yaml
processorsDir:        "processors"                            # commun
processorsOverlayDir: "per-cluster/<variant>/processors"      # override variant
```

Avec :
```
processors/
├── batch.yaml                 # commun
├── memory_limiter.yaml        # commun
└── k8sattributes.yaml         # commun
per-cluster/
├── adm/processors/
│   └── resource_cluster.yaml  # override pour adm
└── downstream/processors/
    └── resource_cluster.yaml  # override pour downstream
```

Le ConfigMap final a tous les processors communs + le `resource_cluster` du variant. La logique de merge est `merge` pour les communs (first wins, mais vu qu'on construit un dict vide initial c'est équivalent à add) puis `mergeOverwrite` pour l'overlay (variant wins).

---

## Référence des values

```yaml
namespace: observability    # ns où sont déployés les composants
name: collector             # base du nom des resources
serviceAccountName: otel-collector
image: otel/opentelemetry-collector-contrib:0.140.1
featureGates: []            # ex: --feature-gates=service.profilesSupport
labels:
  app: opentelemetry
  component: otel-collector

# --- Activation des composants (tous désactivés par défaut) ---
gateway:
  enabled: false
  replicas: 1
  resources: { ... }
  service:
    nodePort:
      enabled: false        # passer à true pour exposer la gateway hors cluster
      port: 30790

agent:
  enabled: false
  resources: { ... }

scraper:
  enabled: false
  replicas: 1               # SINGLETON obligatoire — augmenter dupliquerait les metrics
  resources: { ... }

# --- Paths des fragments (relatifs au répertoire du chart au moment du template) ---
receiversDir:         "receivers"
processorsDir:        "processors"
exportersDir:         "per-cluster/<variant>/exporters"
connectorsDir:        "per-cluster/<variant>/connectors"

# Overlay paths (optionnels). Quand un fragment du même nom existe dans
# l'overlay et dans le path principal, la version de l'overlay écrase.
# Mettre "" (vide) pour désactiver.
receiversOverlayDir:  ""
processorsOverlayDir: "per-cluster/<variant>/processors"
exportersOverlayDir:  ""
connectorsOverlayDir: ""

gatewayPipelinesFile: "pipelines/<variant>/gateway.yaml"
agentPipelinesFile:   "pipelines/<variant>/agent.yaml"
scraperPipelinesFile: "pipelines/<variant>/scraper.yaml"
```

---

## Pièges importants

### 1. Le `scraper` doit rester en `replicas: 1`

Le receiver `prometheus` (et `k8s_cluster`, `k8s_events`) **scrape activement**. Si tu mets `replicas: 2+` sur le scraper, **chaque réplique scrape les mêmes endpoints**, et tu obtiens N copies des mêmes métriques côté backend (`err-mimir-sample-out-of-order` typique). C'est documenté par OpenTelemetry — voir [Scaling the Collector](https://opentelemetry.io/docs/collector/scaling/).

Si tu veux de la HA sans duplication, regarde :
- L'extension `k8s_leader_elector` (GA depuis 2025, contrib OTel)
- `TargetAllocator` de l'opentelemetry-operator (sharding par consistent hashing)

### 2. Ne mets jamais `prometheus` / `k8s_cluster` / `k8s_events` dans la pipeline du gateway

Même piège : le gateway tourne en N répliques. Tout receiver actif y est dupliqué. Réserve ces 3 receivers pour le `scraper`.

### 3. Le gateway ne doit pas avoir de `filelog` non plus

Le `filelog` reçoit du *node-local*, qui appartient au DaemonSet (`agent`). Les pods du gateway peuvent ne pas être sur les mêmes nodes que les apps qui logguent.

### 4. Le filtrage marche sur les noms simples ET avec slash

Si tu nommes ton exporter `otlp/backend`, le filtre matche bien sur le segment avant `/`. Idem pour les pipelines (`metrics`, `metrics/spanmetrics`, etc.).

---

## Exemple complet

Voir [`examples/multi-cluster/`](examples/multi-cluster/) — un setup complet avec :

* 1 variant `adm` (cluster central, 3 composants actifs, exporte vers Mimir)
* 1 variant `downstream` (clusters enfants, push OTLP vers gateway centrale)
* receivers/processors mutualisés au top
* `generate.sh` qui copie les fragments + lance `helm template`

Tester rapidement :

```bash
cd examples/multi-cluster/
./generate.sh adm          # produit rendered-adm.yaml
./generate.sh downstream   # produit rendered-downstream.yaml
```

---

## Convention de nommage des resources rendues

| Composant | Resource | Nom |
|---|---|---|
| gateway | Deployment | `<name>` |
| gateway | Service ClusterIP | `<name>-collector` |
| gateway | Service NodePort (optionnel) | `<name>-collector-nodeport` |
| gateway | ConfigMap | `otel-gateway-configmap` |
| agent | DaemonSet | `<name>-agent` |
| agent | ConfigMap | `otel-agent-configmap` |
| scraper | Deployment | `<name>-scraper` |
| scraper | ConfigMap | `otel-scraper-configmap` |
| RBAC | ServiceAccount + ClusterRole + ClusterRoleBinding | `<serviceAccountName>` |

Le Service du gateway garde le nom `<name>-collector` (et non `<name>-gateway`) pour rester compatible avec les agents downstream qui pointent dessus en hardcodé. Le composant interne s'appelle `gateway` mais le service externe garde `collector` pour ne pas casser les routes existantes.

---

## License

MIT — voir le repo parent.
