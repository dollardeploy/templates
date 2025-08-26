#!/bin/sh
echo "Creating config.json"
cat >/config/config.json <<EOF
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
chmod 666 /config/config.json
EOF
