FROM python:3.10-alpine
RUN apk add --no-cache nodejs npm git && \
    pip install uv && \
    uv tool install git+https://github.com/sparfenyuk/mcp-proxy && \
    git clone https://github.com/huksley/frappe_mcp_server/ && \
    cd frappe_mcp_server && \
    npm install && \
    npm run build

WORKDIR /frappe_mcp_server
CMD ["/root/.local/bin/mcp-proxy", "--host=0.0.0.0", "--port=8096", "--allow-origin=*", "--pass-environment", "npm", "run", "start"]
