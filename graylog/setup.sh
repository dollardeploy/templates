#!/bin/bash
# Generate Graylog secrets once, before the stack starts.
#
# Graylog needs two values that must not be committed to the template:
#   - GRAYLOG_PASSWORD_SECRET:    a long random secret used to pepper stored
#                                 passwords (the .env.example asks for >= 64
#                                 chars, generated with `pwgen -N 1 -s 96`).
#   - GRAYLOG_ROOT_PASSWORD_SHA2: the SHA-256 hash of the admin (root) password
#                                 (the .env.example generates it with
#                                 `echo -n yourpassword | shasum -a 256`).
#
# We write them to .env.password, which docker-compose.yml loads into the
# graylog and datanode containers via the env_file directive. The file is
# created only once so the secrets stay stable across redeploys (changing the
# password secret would invalidate all stored encrypted values and sessions).
set -e

# Load the DollarDeploy-provided env (APP_URL, GENERATED_PWD, PORT, ...).
set -a
[ -f .env ] && source .env
set +a

if [ ! -f .env.password ]; then
  # 96-char random secret (openssl rand -hex 48 == 96 hex chars).
  PASSWORD_SECRET=$(openssl rand -hex 48)
  # SHA-256 of the admin password, exactly as .env.example prescribes.
  ROOT_PASSWORD_SHA2=$(printf '%s' "${GRAYLOG_PASSWORD}" | sha256sum | cut -d' ' -f1)

  cat > .env.password <<EOF
GRAYLOG_PASSWORD_SECRET=${PASSWORD_SECRET}
GRAYLOG_DATANODE_PASSWORD_SECRET=${PASSWORD_SECRET}
GRAYLOG_ROOT_PASSWORD_SHA2=${ROOT_PASSWORD_SHA2}
EOF
  chmod 600 .env.password

  echo "Generated .env.password with Graylog secrets."
else
  echo ".env.password already exists, keeping existing secrets."
fi
