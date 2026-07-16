# ntfy

Send push notifications to your phone or desktop from any script via a simple HTTP PUT/POST — no sign-up required.

> **Experimental template.** Verify the deployment on your own server before relying on it.

## What you get

- Self-hosted [ntfy](https://ntfy.sh) server (`binwiederhier/ntfy`)
- Cache, attachments, and user database persisted to a local `./data` volume

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Host port the app is exposed on (bound to `127.0.0.1`) |
| `AUTH_DEFAULT_ACCESS` | `read-write` | Default access. Set to `deny-all` to require authentication. |

## Usage

Publish a notification to a topic:

```bash
curl -d "Backup finished" https://<your-app-url>/mytopic
```

Subscribe from the [ntfy mobile app](https://ntfy.sh/docs/subscribe/phone/) or the
web UI at your app URL. To lock the server down, set `AUTH_DEFAULT_ACCESS=deny-all`
and create users with the [ntfy CLI](https://docs.ntfy.sh/config/#access-control).
