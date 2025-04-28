FROM python:3.10-alpine
WORKDIR /app
RUN apk add --no-cache nodejs npm git && \
    pip install uv && \
    uv tool install git+https://github.com/sparfenyuk/mcp-proxy && \
    git clone https://github.com/gomarble-ai/facebook-ads-mcp-server/ && \
    cd facebook-ads-mcp-server && \
    cp ./requirements.txt /app

RUN cd /app && pip install --no-cache-dir -r requirements.txt
RUN cd /app/facebook-ads-mcp-server && \
    cp ./server.py /app

ENV FB_TOKEN=dummy_facebook_access_token

# Command to run the MCP server. 
# The Facebook token must be provided via --fb-token argument.
CMD ["/root/.local/bin/mcp-proxy", "--sse-host=0.0.0.0", "--sse-port=8096", "--allow-origin=*", "--pass-environment", "python", "server.py", "--", "--fb-token", "$FB_TOKEN"]
