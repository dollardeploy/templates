# Gitea

Lightweight, self-hosted Git service written in Go — a fast alternative to GitHub/GitLab.

> **Experimental template.** Verify the deployment on your own server before relying on it.

## What you get

- [Gitea](https://gitea.io) server (`gitea/gitea`) with issues, PRs, wiki, and CI hooks
- PostgreSQL 16 database
- Repository data and database persisted to local `./data` and `./postgres` volumes

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `PORT` | `3000` | Host port for the web UI (bound to `127.0.0.1`) |
| `SSH_PORT` | `2222` | Host port for Git-over-SSH — open this in your firewall to use it |
| `DB_PASSWORD` | generated | PostgreSQL password |

## First run

1. Deploy and open the app URL.
2. Complete the initial setup screen (the database is pre-filled).
3. Create the first user — it becomes the admin.

Git over HTTPS works through the app URL immediately. For SSH clones, open the
`SSH_PORT` on your server firewall. See the [Gitea docs](https://docs.gitea.com).
