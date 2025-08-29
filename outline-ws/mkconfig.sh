#!/bin/sh
echo "Creating config.yml"
mkdir -p /config
cat >/config/config.yml <<EOF
web:
  servers:
    - id: my_web_server
      listen:
        - "127.0.0.1:${PORT}"

services:
  - listeners:
      - type: tcp
        address: "[::]:${TCP_PORT}"
      - type: udp
        address: "[::]:${UDP_PORT}"
      - type: websocket-stream
        web_server: my_web_server
        path: "/${URL_PATH}/tcp"
      - type: websocket-packet
        web_server: my_web_server
        path: "/${URL_PATH}/udp"
    keys:
      - id: user-0
        cipher: chacha20-ietf-poly1305
        secret: ${CLIENT_SECRET}
EOF

