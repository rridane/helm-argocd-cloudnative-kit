# 📦 Helm Chart: Filebrowser

Ce chart déploie [Filebrowser](https://filebrowser.org/) dans Kubernetes, avec support optionnel des volumes **NFS**.

## 🚀 Installation

```bash
helm install filebrowser ./filebrowser
```

Par défaut, Filebrowser sera déployé dans le namespace filebrowser, avec un Pod unique, un Service interne et un ConfigMap minimal.

## ⚙️ Valeurs configurables

| Key                       | Type   | Default                                   | Description                                         |
|----------------------------|--------|-------------------------------------------|-----------------------------------------------------|
| `namespace`               | string | `filebrowser`                             | Namespace où déployer                               |
| `replicas`                | int    | `1`                                       | Nombre de pods                                      |
| `image`                   | string | `filebrowser/filebrowser:v2-s6`           | Image Docker                                        |
| `service.port`            | int    | `80`                                      | Port exposé par le service                          |
| `labels`                  | map    | `{app.kubernetes.io/name: filebrowser}`   | Labels appliqués au Deployment et au Service        |
| `storageClassName`        | string | `""`                                      | StorageClass utilisée pour les PVC (vide = statique)|
| `volumes[].name`          | string | —                                         | Nom du volume                                       |
| `volumes[].storage`       | string | —                                         | Capacité demandée (ex: `20Gi`)                      |
| `volumes[].mount_path`    | string | —                                         | Chemin de montage dans le conteneur                 |
| `volumes[].sub_path`      | string | `nil`                                     | Fichier/répertoire spécifique à monter              |
| `volumes[].create_nfs_pv` | bool   | `false`                                   | Créer automatiquement un PV NFS                     |
| `volumes[].nfs_server`    | string | —                                         | Adresse du serveur NFS                              |
| `volumes[].nfs_path`      | string | —                                         | Chemin exporté sur le serveur NFS                   |

## Déploiement avec nfs

```yaml
volumes:
  - name: filebrowser-data
    storage: 20Gi
    mount_path: "/srv"
    create_nfs_pv: true
    nfs_server: 10.33.248.43
    nfs_path: "/mnt/data/kube_data/filebrowser"
```

