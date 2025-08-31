#!/bin/sh
echo "Creating config.json"
mkdir -p /opt/config
cat >/opt/config/config.json <<EOF
{
  "url": "${NODEBB_URL}",
  "secret": "${NODEBB_SECRET}",
  "database": "redis",
  "redis": {
    "host": "redis",
    "port": "6379",
    "password": "${REDIS_PASSWORD}",
    "database": "0"
  },
  "admin:username": "${NODEBB_ADMIN_USERNAME}",
  "admin:password": "${NODEBB_ADMIN_PASSWORD}",
  "admin:password:confirm": "${NODEBB_ADMIN_PASSWORD}",
  "admin:email": "${NODEBB_ADMIN_EMAIL}",
  "port": "4567"
}
EOF

mkdir -p /opt/files
chmod 666 /opt/files
chmod 666 /opt/config/config.json
chown -R 1000 /opt/config
chown -R 1000 /opt/files


