# Vaultwarden

Lightweight, self-hosted password manager compatible with the official Bitwarden clients, written in Rust.

> **Experimental template.** Verify the deployment on your own server before storing production secrets.

## What you get

- OpenAPI-compatible Bitwarden server ([vaultwarden/server](https://github.com/dani-garcia/vaultwarden))
- Data persisted to a local `./data` volume
- Works with all official Bitwarden clients (desktop, browser, mobile, CLI)

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Host port the app is exposed on (bound to `127.0.0.1`) |
| `SIGNUPS_ALLOWED` | `true` | Allow new account registration. Set to `false` after creating your account. |
| `ADMIN_TOKEN` | _(empty)_ | Set to enable the `/admin` panel |

## First run

1. Deploy and open the app URL.
2. Create your account.
3. Set `SIGNUPS_ALLOWED=false` and redeploy to lock down registration.

See the [Vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki) for full configuration.
