#!/bin/sh
echo "Creating config.json"
cat >/config/config.json <<EOF
{
  "url": "${NODEBB_URL}",
  "secret": "${NODEBB_SECRET}",
  "database": "redis",
  "redis:host": "redis",
  "redis:port": "8443",
  "redis:password": "${REDIS_PASSWORD}",
  "port": "${PORT}",
  "admin:username": "${NODEBB_ADMIN_USERNAME}",
  "admin:password": "${NODEBB_ADMIN_PASSWORD}",
  "admin:password:confirm": "${NODEBB_ADMIN_PASSWORD}",
  "admin:email": "${NODEBB_ADMIN_EMAIL}"
}
EOF
