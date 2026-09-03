#!/bin/bash
set -euo pipefail

# Exemple de bridge : rend le chart pour l'un des deux variants (adm ou
# downstream). Le script copie les 4 dossiers (`receivers/`, `processors/`,
# `pipelines/`, `per-cluster/`) dans le chart pour que `Files.Get` /
# `Files.Glob` les trouvent, puis lance `helm template`.

VARIANT="${1:-}"
case "$VARIANT" in
  adm|downstream) ;;
  *) echo "Usage: $0 adm|downstream" >&2; exit 1 ;;
esac

CHART="../.."
OUT="rendered-${VARIANT}.yaml"
DIRS="receivers processors pipelines per-cluster"

cleanup() {
  for d in $DIRS; do rm -rf "$CHART/$d"; done
}
trap cleanup EXIT

for d in $DIRS; do
  rm -rf "$CHART/$d"
  cp -r "$d" "$CHART/$d"
done

helm template otel "$CHART" --values "values-${VARIANT}.yaml" > "$OUT"

echo "Variant : $VARIANT"
echo "Manifest généré : $(pwd)/$OUT"
echo "  Lignes : $(wc -l < "$OUT")"
echo "  Ressources :"
grep -E "^kind:" "$OUT" | sort | uniq -c | sed 's/^/    /'
