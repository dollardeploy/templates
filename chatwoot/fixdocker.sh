#!/bin/bash
mkdir -p data
mkdir -p data/tmp
mkdir -p data/storage
mkdir -p data/postgres
mkdir -p data/redis
docker compose run --rm rails bundle exec rails db:chatwoot_prepare
