# Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is a self-improving AI agent by Nous Research with persistent memory, skills, a cron scheduler, a messaging gateway and a web dashboard.

## How it works

- Runs the official `nousresearch/hermes-agent` image (`HERMES_VERSION`, pinned) with `gateway run`; s6 supervises the gateway and the dashboard (`HERMES_DASHBOARD=1`) in one container
- The dashboard binds `0.0.0.0:9119` inside the container, which engages its mandatory auth gate; the host port is bound to `127.0.0.1` so it is only reachable through DollarDeploy's HTTPS proxy
- Login uses the bundled username/password provider: `admin` / `${GENERATED_HASH}`, with `${GENERATED_SECRET}` as the session signing key so sessions survive restarts
- Health check: `GET /api/health` (unauthenticated, 200)
- State (config, `.env` with API keys, sessions, memories, skills) lives in the `hermes-data` volume at `/opt/data`
- The OpenAI-compatible API server (port 8642) stays container-local

## Stronger auth

Upstream recommends OAuth for internet-facing dashboards. Register the dashboard at https://portal.nousresearch.com/local-dashboards with redirect URI `https://<app-url>/auth/callback`, then set `HERMES_DASHBOARD_OAUTH_CLIENT_ID` in the app env and redeploy. You can also restrict access by IP with `allowAccessFrom`.

## Updating

Change `HERMES_VERSION` to a newer tag from https://hub.docker.com/r/nousresearch/hermes-agent/tags and redeploy.
