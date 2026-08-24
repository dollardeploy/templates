#!/bin/sh
# Generates the OAuth client key on first boot and keeps it in the data volume,
# so sessions survive redeploys.
set -eu

DATA_DIR="$(dirname "${TANGLED_DB_PATH:-/var/lib/appview/appview.db}")"
SECRET="$DATA_DIR/oauth-secret"
KID="$DATA_DIR/oauth-kid"

mkdir -p "$DATA_DIR"

if [ ! -s "$SECRET" ]; then
    # --terse prints the multibase secret and nothing else. Upstream's dev
    # entrypoint greps the verbose output instead, but the nix image ships no
    # awk, so that pipeline dies here and takes the container with it.
    goat key generate -t P-256 --terse > "$SECRET"
    date +%s > "$KID"
    echo "[oauth] generated client key kid=$(cat "$KID")"
fi

# base58btc multibase always starts with z; anything else won't parse and the
# appview would exit into a restart loop with a much less obvious message.
case "$(cat "$SECRET")" in
    z*) ;;
    *)
        echo "[oauth] $SECRET is not a multibase key — delete it and redeploy" >&2
        exit 1
        ;;
esac

TANGLED_OAUTH_CLIENT_SECRET="$(cat "$SECRET")"
TANGLED_OAUTH_CLIENT_KID="$(cat "$KID")"
export TANGLED_OAUTH_CLIENT_SECRET TANGLED_OAUTH_CLIENT_KID

exec appview
