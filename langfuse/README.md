# Langfuse

Open source LLM engineering platform: tracing, evals, prompt management and metrics.

## What you get

Full Langfuse v4 stack, adapted from the upstream [docker-compose.yml](https://github.com/langfuse/langfuse/blob/main/docker-compose.yml):

- `langfuse-web` (UI + API), published on `127.0.0.1:${PORT}` behind the DollarDeploy proxy
- `langfuse-worker` (async ingestion)
- PostgreSQL, ClickHouse, Redis and MinIO on the private compose network only (no host ports)

Data is persisted in Docker volumes (`langfuse_*_data`).

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `LANGFUSE_IMAGE_TAG` | `4.77.0` | Langfuse web + worker image tag. Change and redeploy to upgrade |
| `CLICKHOUSE_IMAGE_TAG` | `26.3.62.3` | ClickHouse image tag |
| `POSTGRES_IMAGE_TAG` | `17` | PostgreSQL image tag |
| `REDIS_IMAGE_TAG` | `7` | Redis image tag |
| `NEXTAUTH_URL` | `${APP_URL}` | Public URL of the app |
| `NEXTAUTH_SECRET`, `SALT`, `ENCRYPTION_KEY` | generated | Langfuse secrets. Do not change after first launch |
| `POSTGRES_PASSWORD`, `CLICKHOUSE_PASSWORD`, `REDIS_AUTH`, `MINIO_ROOT_PASSWORD` | generated | Internal service passwords. Do not change after first launch |
| `AUTH_DISABLE_SIGNUP` | `true` | Set to `false` to allow public sign up |
| `LANGFUSE_INIT_USER_EMAIL` | your e-mail | Admin user created on first launch |
| `LANGFUSE_INIT_USER_PASSWORD` | generated | Admin user password |
| `APP_HEALTHCHECK_PATH` | `/api/public/health` | DollarDeploy health check path |

Any other [Langfuse setting](https://langfuse.com/self-hosting/configuration) (for example `SMTP_CONNECTION_URL`, `EMAIL_FROM_ADDRESS` or `AUTH_*` SSO providers) can be added to the app environment. It is passed to web and worker via `.env`.

## First run

1. Deploy and open the app URL.
2. Log in with your e-mail and the password from `LANGFUSE_INIT_USER_PASSWORD`.
3. Open the `Default` project, go to **Project Settings -> API Keys** and create a key pair.
4. Configure the SDK with `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY` and `LANGFUSE_HOST` set to the app URL.

## Upgrading

Change `LANGFUSE_IMAGE_TAG` to a newer [release](https://github.com/langfuse/langfuse/releases) and redeploy. Migrations run automatically on start.

## Limitations

MinIO is not exposed publicly, so multi-modal media uploads from SDK clients (presigned URLs) and batch exports to blob storage do not work out of the box. To enable them, point `LANGFUSE_S3_MEDIA_UPLOAD_*` to an external S3 compatible bucket.

Upstream recommends at least 4 cores and 16 GiB memory for production workloads.
