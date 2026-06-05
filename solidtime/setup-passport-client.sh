#!/bin/bash
# Create the Laravel Passport "personal access client" so Solidtime's
# "Create API Token" feature works. Passport 13 resolves this client from the
# database by grant type (no env vars needed) — it just has to exist.
#
# The client lives in Postgres (persisted volume) and this marker file lives in
# the project dir (also persisted), so this runs only on the first deploy.
set -e

[ -f ./.passport_personal_done ] && exit 0

# The stack may still be finishing migrations when post-start fires; retry a bit.
for i in $(seq 1 12); do
  if docker compose exec -T scheduler \
       php artisan passport:client --personal --name="solidtime" --no-interaction >/dev/null 2>&1; then
    touch ./.passport_personal_done
    echo "Created Passport personal access client."
    exit 0
  fi
  sleep 5
done

# Best-effort: don't fail the deploy if it didn't work — the app is still usable,
# and the user can create the client manually.
echo "WARNING: could not create Passport personal access client automatically." >&2
echo "Run it manually once the stack is up:" >&2
echo "  docker compose exec scheduler php artisan passport:client --personal --name=solidtime --no-interaction" >&2
exit 0
