#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Uso: $0 <slug_projeto> <nome_legivel>"
  exit 1
fi

SLUG="$1"
NAME="$2"
ROOT="$HOME/Malachias"
TEMPLATE="$ROOT/projects/_template-next"
DEST="$ROOT/projects/$SLUG"

# cria cópia base
cp -r "$TEMPLATE" "$DEST"

cd "$DEST"
git init
git add .
git commit -m "Bootstrap do projeto $NAME"

# cria o projeto na vercel
vercel link --project "$SLUG" --confirm --token "$VERCEL_TOKEN"
PREVIEW_URL=$(vercel deploy --prebuilt --token "$VERCEL_TOKEN" | tail -n1)

# adiciona DNS preview
python3 "$ROOT/scripts/cf_dns_upsert.py" \
  --zone-id "$CLOUDFLARE_ZONE_ID" \
  --token "$CLOUDFLARE_API_TOKEN" \
  --name "preview.${SLUG}.108mia.com" \
  --type "CNAME" \
  --content "$(echo "$PREVIEW_URL" | sed 's~https://~~')" \
  --proxied true

echo "✅ Projeto criado: $SLUG → $PREVIEW_URL"
