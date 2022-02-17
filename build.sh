#!/bin/bash
set -e

# use buildkit
export DOCKER_BUILDKIT=1

# build the image
docker build \
  --pull \
  --no-cache \
  --progress=plain \
  --label "org.opencontainers.image.created=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --label "org.opencontainers.image.authors=Simon Frankenberger <simon-docker@fraho.eu>" \
  --label "org.opencontainers.image.url=https://github.com/bratkartoffel/teamspeak3-docker" \
  --label "org.opencontainers.image.source=$(git remote get-url origin)" \
  --label "org.opencontainers.image.revision=$(git log -1 --format=%H)" \
  --label "org.opencontainers.image.licenses=MIT" \
  --label "org.opencontainers.image.title=teamspeak3 running on alpine in docker" \
  --label "org.opencontainers.image.base.name=alpine:3.15" \
  --tag bratkartoffel/teamspeak3:latest \
  .

# push it
docker push bratkartoffel/teamspeak3:latest

