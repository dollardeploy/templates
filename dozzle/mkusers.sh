#!/bin/sh
if [ ! -f /data/users.yml ]; then 
  PWD=$(bcrypt hash "${DOZZLE_AUTH_PASSWORD}")
  echo "Password hash generated: ${DOZZLE_AUTH_PASSWORD}"
  cat >/data/users.yml <<EOF
users:
  admin:
    email: ${DOZZLE_AUTH_EMAIL}
    name: Admin
    password: ${PWD} 
EOF
fi
