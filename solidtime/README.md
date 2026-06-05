# Solidtime

Modern, open-source time tracker — a privacy-friendly, self-hostable alternative to
Toggl and Clockify. Track time across projects and clients, manage organizations and
teams, set billable rates, and generate reports and PDF invoices. Built on Laravel +
Vue.

This template runs the official production image (`solidtime/solidtime`) as an
all-in-one stack:

* **app** — FrankenPHP/Octane web server (port 8000)
* **scheduler** — Laravel scheduler
* **queue** — queue worker
* **database** — PostgreSQL 15 (data in the `database-storage` volume)
* **gotenberg** — headless Chromium for PDF/export generation

## Links

* https://www.solidtime.io/
* https://docs.solidtime.io/self-hosting/guides/docker
* https://github.com/solidtime-io/solidtime
* https://github.com/solidtime-io/self-hosting-examples/tree/main/1-docker-with-database
* https://hub.docker.com/r/solidtime/solidtime/tags

## Notes

* DollarDeploy terminates TLS and reverse-proxies to `127.0.0.1:${PORT}` (8000),
  so the app port is only bound to localhost.
* `fixdocker.sh` (run as `preStartCmd`) generates the `laravel.env` consumed by the
  app containers and creates a **stable** `APP_KEY` and Laravel Passport RSA keypair
  on first deploy, persisting them in the project directory so redeploys don't
  invalidate sessions or encrypted data.
* `AUTO_DB_MIGRATE=true` runs migrations automatically on boot (`--isolated` lock
  prevents the three app containers from racing).
* The deploying user's email is set as a `SUPER_ADMINS` entry — register with it to
  get an admin account.
* Mail defaults to the `log` driver; configure `MAIL_*` in `fixdocker.sh` / env and
  redeploy to send real email.
