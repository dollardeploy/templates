#!/bin/bash
# Create the Laravel Passport OAuth clients Solidtime needs, after the stack is up.
# Passport 13 resolves clients from the database, so these just have to exist; the
# DB (persisted volume) + marker files (persisted project dir) make this run once.
set -e

run() { docker compose exec -T scheduler php artisan "$@"; }

# 1) Personal access client — enables the "Create API Token" feature.
if [ ! -f ./.passport_personal_done ]; then
  for i in $(seq 1 12); do
    if run passport:client --personal --name="solidtime" --no-interaction >/dev/null 2>&1; then
      touch ./.passport_personal_done
      echo "Created Passport personal access client."
      break
    fi
    sleep 5
  done
fi

# 2) Desktop / Instance OAuth client — used to connect the Solidtime desktop app
#    (and as the template for browser extensions). Public PKCE client.
if [ ! -f ./.passport_desktop_done ]; then
  if run passport:client --name="desktop" --redirect_uri="solidtime://oauth/callback" --public -n >/dev/null 2>&1; then
    # Read the generated client id back cleanly via delimited markers.
    out=$(run tinker --execute="echo 'CID:'.optional(\Laravel\Passport\Client::where('name','desktop')->latest('created_at')->first())->getKey().':END';" 2>/dev/null || true)
    cid=$(printf '%s' "$out" | sed -n 's/.*CID:\(.*\):END.*/\1/p')
    if [ -n "$cid" ]; then
      echo "$cid" > ./instance-client-id.txt
      touch ./.passport_desktop_done
      echo "============================================================"
      echo " Solidtime Instance Client ID (desktop app / extension):"
      echo "   $cid"
      echo " (also saved to ./instance-client-id.txt)"
      echo "============================================================"
    fi
  fi
fi

# Best-effort: never fail the deploy over client setup — the app is still usable,
# and anything missing can be created manually.
exit 0
