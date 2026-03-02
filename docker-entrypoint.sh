#!/bin/sh
set -e

# Verdaccio runs as UID 10001, GID 65533 in the official image
VERDACCIO_UID="10001"
VERDACCIO_GID="65533"
VERDACCIO_STORAGE="/verdaccio/storage"
VERDACCIO_CONFIG="/verdaccio/conf/config.yaml"
LISTEN_PORT="${PORT:-4873}"

# Ensure storage directory exists and is writable.
# Required when using mounted volumes (e.g. Railway, Docker Compose)
# that default to root ownership.
mkdir -p "${VERDACCIO_STORAGE}"
chown -R "${VERDACCIO_UID}:${VERDACCIO_GID}" "${VERDACCIO_STORAGE}"

# Drop privileges and start Verdaccio
exec su -s /bin/sh "#${VERDACCIO_UID}" -c \
  "verdaccio --config ${VERDACCIO_CONFIG} --listen http://0.0.0.0:${LISTEN_PORT}"
