# Twenty CRM template

This is a template folder for Twenty CRM. 

## Upgrading

NOTE: Remember to backup your app before doing an upgrade.

See [official upgrade](https://twenty.com/developers/section/self-hosting/upgrade-guide) guide first.

To upgrade between releases, change environment variable TAG to a new version (see [docker tags](https://hub.docker.com/r/twentycrm/twenty/tags)) for example v2.38.1 etc, then redeploy.

Since v1.23 Twenty supports cross-version upgrades — you can jump directly from any supported version to the latest release without stepping through each intermediate version.

Database migrations run automatically on server startup, so no manual `database:migrate:prod` / `command:prod upgrade` step is needed after a redeploy.

## Links

* Releases: https://twenty.com/releases
* Recent container releases: https://hub.docker.com/r/twentycrm/twenty/tags
* Upgrade guide: https://twenty.com/developers/section/self-hosting/upgrade-guide
* Self-hosting with Docker Compose: https://twenty.com/developers/section/self-hosting/docker-compose


