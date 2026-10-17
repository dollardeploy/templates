# OpenAGI

[OpenAGI](https://github.com/Spshulem/openAGI) is a proactive personal AI agent daemon: it learns your routines, drafts skills for them and reaches out first.

This template builds OpenAGI from the upstream `Dockerfile` at a pinned release tag (the GHCR image is private) and runs it behind the DollarDeploy reverse proxy.

## How it works

- `docker-compose.yml` is written into the cloned openAGI repo and builds it
- Port `43210` is bound to `127.0.0.1` only; DollarDeploy serves it over HTTPS
- `OPENAGI_AUTH_TOKEN` is generated per deploy (`${GENERATED_SECRET}`); the daemon refuses to start without it
- `OPENAGI_PUBLIC_URL` is set to the app URL so Telegram/Twilio webhooks verify correctly
- State lives in the `openagi-data` volume mounted at `/data`

## After deploy

Open `https://<app-url>/setup?token=<OPENAGI_AUTH_TOKEN>` and enter your Anthropic or OpenAI key. Keys are saved to `/data/.env` on the server. Do not add empty `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` vars to the compose environment: process env wins over `/data/.env`, so a blank value hides the wizard-saved key.

## Updating

Bump `sourceBranch` in `.dollardeploy.yml` to a newer tag from https://github.com/Spshulem/openAGI/tags.

## License

OpenAGI is licensed under PolyForm Noncommercial 1.0.0.
