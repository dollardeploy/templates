#!/bin/bash
set -e

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

# Build the application env file consumed by the app/scheduler/queue containers.
# DollarDeploy substitutes the ${...} placeholders below at deploy time.
{
  echo 'APP_NAME="solidtime"'
  echo 'VITE_APP_NAME="solidtime"'
  echo 'APP_ENV="production"'
  echo 'APP_DEBUG="false"'
  echo 'APP_URL="${APP_URL}"'
  echo 'APP_FORCE_HTTPS="true"'
  echo 'TRUSTED_PROXIES="0.0.0.0/0,2000:0:0:0:0:0:0:0/3"'
  echo 'LOG_CHANNEL="stderr"'
  echo 'LOG_LEVEL="error"'
  echo 'AUTO_DB_MIGRATE="true"'
  echo 'DB_CONNECTION="pgsql"'
  echo 'DB_HOST="database"'
  echo 'DB_PORT="5432"'
  echo 'DB_SSLMODE="disable"'
  echo 'DB_DATABASE="${DB_DATABASE}"'
  echo 'DB_USERNAME="${DB_USERNAME}"'
  echo 'DB_PASSWORD="${DB_PASSWORD}"'
  echo 'QUEUE_CONNECTION="database"'
  echo 'FILESYSTEM_DISK="local"'
  echo 'PUBLIC_FILESYSTEM_DISK="public"'
  echo 'GOTENBERG_URL="http://gotenberg:3000"'
  echo 'SUPER_ADMINS="${USER_EMAIL}"'
  echo 'MAIL_MAILER="log"'
  echo 'MAIL_FROM_ADDRESS="no-reply@${APP_HOSTNAME}"'
  echo 'MAIL_FROM_NAME="solidtime"'
  printf 'APP_KEY="%s"\n' "$(cat ./app_key.txt)"
  printf 'PASSPORT_PRIVATE_KEY="%s"\n' "$(cat ./oauth-private.key)"
  printf 'PASSPORT_PUBLIC_KEY="%s"\n' "$(cat ./oauth-public.key)"
} > laravel.env
