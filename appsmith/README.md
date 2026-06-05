# Appsmith

Open-source, low-code platform to build, ship, and maintain internal tools — admin
panels, dashboards, CRUD apps, and workflows. Connect to any database or REST/GraphQL
API, compose UIs from pre-built widgets, and add logic with JavaScript anywhere.

The all-in-one container bundles the backend, real-time service, MongoDB, and Redis,
so no external services are required. Data is persisted to `./stacks`
(`/appsmith-stacks` inside the container).

## Links

* https://www.appsmith.com/
* https://docs.appsmith.com/
* https://docs.appsmith.com/getting-started/setup/installation-guides/docker
* https://hub.docker.com/r/appsmith/appsmith-ee/tags

## Notes

* DollarDeploy terminates TLS and reverse-proxies to `$PORT`, so only Appsmith's
  HTTP port (80) is exposed, bound to `127.0.0.1`. Do not publish 443.
* First boot takes a few minutes while MongoDB and the backend initialize.
* On first visit, create the initial admin account via the signup screen.
