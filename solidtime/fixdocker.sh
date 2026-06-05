#!/bin/bash
set -e

# Load deploy-time variables. DollarDeploy makes the template `env` map available
# to docker compose — either as a ./.env file and/or as exported shell env. We
# source the .env (if present) so values like APP_URL / DB_PASSWORD are usable
# here as real shell variables, rather than relying on file-content substitution.
set -a
[ -f ./.env ] && . ./.env
set +a

# Persisted app storage + logs (bind-mounted into the containers, owned by the
# image's runtime user 1000:1000).
mkdir -p ./app-storage ./logs
sudo chown -R 1000:1000 ./app-storage ./logs || true

# Generate stable secrets ONCE and persist them in the project dir so they
# survive redeploys (otherwise OAuth tokens and encrypted data would break).
if [ ! -f ./app_key.txt ]; then
  echo "base64:$(openssl rand -base64 32)" > ./app_key.txt
fi
if [ ! -f ./oauth-private.key ]; then
  openssl genrsa -out ./oauth-private.key 4096
  openssl rsa -in ./oauth-private.key -pubout -out ./oauth-public.key
fi
chmod 600 ./app_key.txt ./oauth-private.key

# Fail loudly if the required values didn't arrive, instead of writing a broken
# laravel.env that silently misconfigures the app. APP_URL/APP_HOSTNAME/USER_EMAIL
# are DollarDeploy reserved vars, so the template passes them in via the
# non-reserved aliases PUBLIC_URL / PUBLIC_HOSTNAME / ADMIN_EMAIL.
: "${PUBLIC_URL:?PUBLIC_URL not set}"
: "${DB_DATABASE:?DB_DATABASE not set}"
: "${DB_USERNAME:?DB_USERNAME not set}"
: "${DB_PASSWORD:?DB_PASSWORD not set}"

# Build the application env file consumed by the app/scheduler/queue containers.
cat > laravel.env <<EOF
APP_NAME="solidtime"
VITE_APP_NAME="solidtime"
APP_ENV="production"
APP_DEBUG="false"
APP_URL="${PUBLIC_URL}"
APP_FORCE_HTTPS="true"
TRUSTED_PROXIES="0.0.0.0/0,2000:0:0:0:0:0:0:0/3"
LOG_CHANNEL="stderr"
LOG_LEVEL="error"
AUTO_DB_MIGRATE="true"
DB_CONNECTION="pgsql"
DB_HOST="database"
DB_PORT="5432"
DB_SSLMODE="disable"
DB_DATABASE="${DB_DATABASE}"
DB_USERNAME="${DB_USERNAME}"
DB_PASSWORD="${DB_PASSWORD}"
QUEUE_CONNECTION="database"
FILESYSTEM_DISK="local"
PUBLIC_FILESYSTEM_DISK="public"
GOTENBERG_URL="http://gotenberg:3000"
SUPER_ADMINS="${ADMIN_EMAIL}"
MAIL_MAILER="log"
MAIL_FROM_ADDRESS="no-reply@${PUBLIC_HOSTNAME:-localhost}"
MAIL_FROM_NAME="solidtime"
APP_KEY="$(cat ./app_key.txt)"
PASSPORT_PRIVATE_KEY="$(cat ./oauth-private.key)"
PASSPORT_PUBLIC_KEY="$(cat ./oauth-public.key)"
EOF
