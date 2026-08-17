#!/bin/sh
# Generates the OAuth client key on first boot and keeps it in the data volume,
# so sessions survive redeploys. Mirrors upstream localinfra/appview.Dockerfile.
set -eu

DATA_DIR="$(dirname "${TANGLED_DB_PATH:-/var/lib/appview/appview.db}")"
SECRET="$DATA_DIR/oauth-secret"
KID="$DATA_DIR/oauth-kid"

mkdir -p "$DATA_DIR"

if [ ! -s "$SECRET" ]; then
    goat key generate -t P-256 \
        | grep -A1 'Secret Key' | tail -n1 | awk '{print $1}' \
        > "$SECRET"
    date +%s > "$KID"
    echo "[oauth] generated client key kid=$(cat "$KID")"
fi

TANGLED_OAUTH_CLIENT_SECRET="$(cat "$SECRET")"
TANGLED_OAUTH_CLIENT_KID="$(cat "$KID")"
export TANGLED_OAUTH_CLIENT_SECRET TANGLED_OAUTH_CLIENT_KID

exec appview
