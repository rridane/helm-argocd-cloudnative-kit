# rancher-rbac

Chart générique pour déclarer le RBAC Rancher en YAML.

## Ce qu'il génère

À partir d'une `values.yaml` qui liste les clusters, les groupes Keycloak, les projects globaux et leurs bindings :

- **1× GlobalRole** custom (cluster-scoped sur le local cluster Rancher)
- **N× RoleTemplate** project-scoped
- **N× GlobalRoleBinding** : groupes Keycloak → rôle global `user` (login Rancher) + groupes → GlobalRole custom
- **Pour chaque cluster managé, pour chaque project défini globalement** :
  - `Project` (nom = `project.name`, dans le namespace du cluster)
  - `ProjectRoleTemplateBinding` mappant un groupe Keycloak à un RoleTemplate

## values.yaml — squelette

```yaml
globalRole:
  name: my-global-role
  displayName: My Global Role
  rules: [ ... ]

roleTemplates:
  extended:
    name: my-role-extended
    displayName: My Role Extended
    rules: [ ... ]
  basics:
    name: my-role-basics
    displayName: My Role Basics
    rules: [ ... ]

keycloakGroups:
  productLeads: development-product-leads
  projectLeads: development-project-leads

allowedLoginGroups: [productLeads, projectLeads]
allowedGlobalRoleGroups: [productLeads, projectLeads]

projects:
  - name: invoice-apps
    displayName: invoice-apps
    description: Application workloads
    bindings:
      - { group: productLeads, role: extended }
      - { group: projectLeads, role: basics }
  - name: tooling
    displayName: tooling
    description: Shared tooling
    bindings:
      - { group: productLeads, role: extended }

clusters:
  - { id: c-xqtqn, label: prd-pa }
  - { id: c-rzwj7, label: re-pp-pa }
```

## Sémantique

- `keycloakGroups` est l'annuaire alias → vrai nom Keycloak. Toutes les autres sections référencent l'alias.
- `allowedLoginGroups` : qui peut se connecter à l'UI Rancher (rôle `user`).
- `allowedGlobalRoleGroups` : qui obtient le GlobalRole custom (droits read globaux).
- `projects[]` : projects globaux, **chacun appliqué à tous les clusters listés**.
- Chaque project porte son propre `bindings[]` (mapping groupe → rôle dans CE project).
- `clusters[]` : la liste des clusters Rancher gérés.

## Sync-waves ArgoCD

- `Project` → wave 0
- `ProjectRoleTemplateBinding` → wave 1

Le Project doit être appliqué avant les PRTBs : Rancher crée le backing namespace (`<cluster-id>-<project-name>`) à la création du Project, et les PRTBs vivent dans ce namespace.

## Hors scope

Ce chart ne gère **pas** le mapping namespace → project (annotation `field.cattle.io/projectId` posée sur les namespaces des clusters downstream). À gérer séparément (UI Rancher ou script `kubectl annotate`).

## Usage

```bash
helm template rbac . --values myvalues.yaml > rbac.yaml
```

Ou en dépendance d'un chart parapluie (umbrella) qui l'appelle avec ses values.
