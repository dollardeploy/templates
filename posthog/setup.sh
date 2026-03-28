#!/bin/bash
set -e

# Load env vars from DollarDeploy .env
set -a
[ -f .env ] && source .env
set +a

PORT=${PORT:-8000}

# Extract domain from APP_URL (remove protocol and trailing path)
DOMAIN=$(echo "${APP_URL}" | sed -E 's|^https?://||' | sed 's|/.*||')

# Generate encryption salt
ENCRYPTION_SALT_KEYS=$(openssl rand -hex 16)

# Append derived vars to .env
cat >> .env <<EOF
DOMAIN=${DOMAIN}
ENCRYPTION_SALT_KEYS=${ENCRYPTION_SALT_KEYS}
EOF

# Clone PostHog repository — needed for ClickHouse, Temporal, and Livestream config files
if [ ! -d "posthog" ]; then
    git clone --depth 1 https://github.com/PostHog/posthog.git posthog
fi

# Create compose entrypoint scripts (mounted into web & temporal-django-worker containers)
mkdir -p compose

cat > compose/start <<'SCRIPT'
#!/bin/bash
./compose/wait
./bin/migrate
./bin/docker-server
SCRIPT
chmod +x compose/start

cat > compose/temporal-django-worker <<'SCRIPT'
#!/bin/bash
./bin/temporal-django-worker
SCRIPT
chmod +x compose/temporal-django-worker

cat > compose/wait <<'SCRIPT'
#!/usr/bin/env python3
import socket
import time

def loop():
    print("Waiting for ClickHouse and Postgres to be ready")
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(('clickhouse', 9000))
        print("ClickHouse is ready")
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(('db', 5432))
        print("Postgres is ready")
    except ConnectionRefusedError:
        time.sleep(5)
        loop()

loop()
SCRIPT
chmod +x compose/wait

# Download GeoIP database for geolocation features
mkdir -p share
if [ ! -f ./share/GeoLite2-City.mmdb ]; then
    apt-get install -y --no-install-recommends brotli 2>/dev/null || true
    curl -sL 'https://mmdbcdn.posthog.net/' --http1.1 | brotli --decompress > ./share/GeoLite2-City.mmdb 2>/dev/null || true
    echo "{\"date\": \"$(date +%Y-%m-%d)\"}" > ./share/GeoLite2-City.json || true
fi
