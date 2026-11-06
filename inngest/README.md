# Inngest

Self-hosted Inngest server with Postgres and Redis.

The Inngest image version is controlled by the `TAG` env variable. New launches use `v1.49.0`. Apps launched earlier keep the `TAG` they were launched with when redeployed.

## Upgrading an existing app

Inngest v1.18.0 rolled up the self-hosted database migrations. The rollup only runs `CREATE IF NOT EXISTS`, so upgrading a database created by a version older than v1.17.x directly to v1.18 or newer can break it.

If your app runs `TAG=v1.12.x` (or any version older than v1.17.x), upgrade in two steps:

1. Set `TAG` to `v1.17.9` and redeploy. Wait until Inngest starts and the dashboard loads.
2. Set `TAG` to `v1.49.0` and redeploy.

Back up the `postgres_data` volume before upgrading.

## Links

* https://www.inngest.com/docs/self-hosting
* https://github.com/inngest/inngest
* https://github.com/inngest/inngest/releases/tag/v1.18.0
