# builds the cobalt web frontend (static sveltekit) and serves it with nginx,
# which also proxies /api/ and /tunnel to the cobalt api container.
FROM node:24-alpine AS build

ARG COBALT_REF=main
# both are baked in at build time — sveltekit has no runtime env
ARG WEB_DEFAULT_API
ARG WEB_HOST
ENV WEB_DEFAULT_API=${WEB_DEFAULT_API}
ENV WEB_HOST=${WEB_HOST}

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && apk add --no-cache git

WORKDIR /app
RUN git clone --depth 1 --branch "${COBALT_REF}" https://github.com/imputnet/cobalt.git .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=@imput/cobalt-web build

FROM nginx:alpine
COPY --from=build /app/web/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY cobalt-proxy.conf /etc/nginx/cobalt-proxy.conf
