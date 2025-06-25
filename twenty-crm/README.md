# Twenty CRM template

This is a template folder for Twenty CRM. 

## Upgrading

NOTE: Remember to backup your app before doing an upgrade.

See [official upgrade](https://twenty.com/developers/section/self-hosting/upgrade-guide) guide first.

To upgrade between releases, change environment variable TAG to a new version (see [docker tags](https://hub.docker.com/r/twentycrm/twenty/tags)) for example v1.0.0 etc.

Do not jump between minor versions, i.e. upgrade sequentially v0.55 => v0.56 => v0.57 ....

After deploying a new version, run manually on the host, in the app folder:

```
docker compose exec server "yarn database:migrate:prod"
docker compose exec server "yarn command:prod upgrade"
```

## Links

* Releases: https://twenty.com/releases
* Recent container releases: https://hub.docker.com/r/twentycrm/twenty/tags
* Upgrade guide: https://twenty.com/developers/section/self-hosting/upgrade-guide
* Self-hosting with Docker Compose: https://twenty.com/developers/section/self-hosting/docker-compose


