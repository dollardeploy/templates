# Outline

The fastest knowledge base for growing teams. Beautiful, realtime collaborative, feature packed, and markdown compatible. 

## Links

* https://www.getoutline.com/
* https://github.com/outline/outline
* Variables https://github.com/outline/outline/blob/main/.env.sample
* Latest images: https://hub.docker.com/r/outlinewiki/outline/tags

## Versions

New launches use `IMAGE_TAG=1.12.0` and `POSTGRES_VERSION=17.10`. Apps launched earlier keep the `IMAGE_TAG` they were launched with, and Postgres stays on `latest` while `POSTGRES_VERSION` is unset.

## Upgrading an existing app

Outline 1.12.0 compacted all migrations before v1.3.0 into a baseline ([#13973](https://github.com/outline/outline/pull/13973)). A database created by a version older than v1.3.0 (for example 0.84.0 or 0.86.1) fails to migrate when it is started directly on 1.12.0 or newer.

If you bump `IMAGE_TAG` manually from a 0.x version, step through an intermediate version first:

1. Set `IMAGE_TAG=1.10.1` (any version between v1.3.0 and v1.10.1 works), redeploy and wait until Outline has started and finished its migrations.
2. Set `IMAGE_TAG=1.12.0` and redeploy again.

Back up the `database-data` volume before upgrading.

### Postgres

PostgreSQL 18+ images store data under `/var/lib/postgresql/18/docker` and refuse to start with the `/var/lib/postgresql/data` mount this template uses ([docker-library/postgres#1259](https://github.com/docker-library/postgres/pull/1259)). Keep `POSTGRES_VERSION` on a 17.x tag. If your app has no `POSTGRES_VERSION` set and Postgres fails to start after a redeploy, set `POSTGRES_VERSION` to the major version your data was created with (check `PG_VERSION` in the volume) and redeploy.
