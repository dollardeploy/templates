# MCP Proxy with Frappe MCP Server

This setup runs [MCP Proxy](https://github.com/sparfenyuk/mcp-proxy) and [Frappe MCP Server](https://github.com/appliedrelevance/frappe_mcp_server) in a single container to provide an MCP server over SSE transport.

## Features

- Single container solution using Python Alpine with Node.js
- MCP Proxy installed directly from GitHub using `uv`
- Frappe MCP Server installed via npm
- Exposes a Frappe MCP Server via SSE transport using MCP Proxy
- Persists data in a local volume
- Accessible from any network interface (0.0.0.0)
- Ready for deployment with Docker Compose or Dollar Deploy

## Quick Start

### Using Docker Compose

1. Clone this repository
2. Navigate to the `mcp-frappe` directory
3. Run `docker-compose up -d`
4. The MCP server will be available at `http://localhost:8096/sse`

### Using Dollar Deploy

1. Clone this repository
2. Navigate to the `mcp-frappe` directory
3. Run `dollar deploy .`
4. The MCP server will be available at the provided URL

## Configuration

You can configure the service using environment variables:

- `PORT`: The port on which the SSE server will be exposed (default: 8096)
- `FRAPPE_URL`: URL of the Frappe server (default: http://localhost:8000)
- `FRAPPE_API_KEY`: API key for Frappe (default: frappe)
- `FRAPPE_API_SECRET`: API secret for Frappe (default: 123)

Example:

```bash
# Docker Compose
PORT=9000 FRAPPE_URL=http://frappe.example.com docker-compose up -d

# Dollar Deploy
dollar deploy . --env PORT=9000 --env FRAPPE_URL=http://frappe.example.com
```

## Usage with LLM Clients

This setup allows LLM clients to connect to the Frappe MCP Server via SSE transport. You can use it with:

- Claude Desktop
- Other LLM clients that support SSE connections

## Architecture

```
LLM Client <-- SSE --> MCP Proxy + Frappe MCP Server (Single Container)
```

The MCP Proxy runs the Frappe MCP Server and exposes it via SSE transport in the same container.

## Troubleshooting

If you encounter any issues:

1. Check the logs with `docker-compose logs` or `dollar logs <deployment-name>`
2. Ensure port 8096 (or your custom port) is not already in use
3. Make sure the container is running with `docker-compose ps` or `dollar status`

## References

- [MCP Proxy GitHub Repository](https://github.com/sparfenyuk/mcp-proxy)
- [Frappe MCP Server GitHub Repository](https://github.com/appliedrelevance/frappe_mcp_server)
