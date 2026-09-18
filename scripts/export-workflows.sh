#!/usr/bin/env bash
# Exports all n8n workflows as readable JSON into ./workflows
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
# Find the running n8n container by image, ignoring runner and sandbox containers
N8N_CONTAINER="${N8N_CONTAINER:-$(docker ps --format '{{.Names}} {{.Image}}' | awk '$2 ~ /(^|\/)n8nio\/n8n:/ {print $1; exit}')}"
if [ -z "$N8N_CONTAINER" ]; then
  echo "No running n8n container found. Start the stack, or set N8N_CONTAINER=<name>." >&2
  exit 1
fi
docker exec "$N8N_CONTAINER" sh -c 'rm -rf /home/node/.n8n/exports && n8n export:workflow --all --pretty --separate --output=/home/node/.n8n/exports'
docker cp "$N8N_CONTAINER:/home/node/.n8n/exports/." "$REPO/workflows/"
echo "Exported from $N8N_CONTAINER to $REPO/workflows"
