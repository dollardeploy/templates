# Umami

Privacy-focused, GDPR-compliant web analytics — a simple, self-hosted Google Analytics alternative.

> **Experimental template.** Verify the deployment on your own server before relying on it.

## What you get

- [Umami](https://umami.is) app (`ghcr.io/umami-software/umami`)
- PostgreSQL 16 database with data persisted to a local `./data` volume

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `PORT` | `3000` | Host port the app is exposed on (bound to `127.0.0.1`) |
| `DB_PASSWORD` | generated | PostgreSQL password |
| `APP_SECRET` | generated | Secret used to sign auth tokens |

## First run

1. Deploy and open the app URL.
2. Log in with the default credentials `admin` / `umami`.
3. Change the password immediately under **Settings → Profile**.
4. Add your website and copy the tracking snippet.

See the [Umami docs](https://umami.is/docs) for details.
