#!/bin/sh
set -e

VERDACCIO_USER="verdaccio"
VERDACCIO_STORAGE="/verdaccio/storage"
VERDACCIO_CONFIG="/verdaccio/conf/config.yaml"
LISTEN_PORT="${PORT:-4873}"

# Ensure storage directory exists and is writable by the verdaccio user.
# Required when using mounted volumes (e.g. Railway, Docker Compose)
# that default to root ownership.
mkdir -p "${VERDACCIO_STORAGE}"
chown -R "${VERDACCIO_USER}:${VERDACCIO_USER}" "${VERDACCIO_STORAGE}"

# Drop privileges and start Verdaccio
exec su -s /bin/sh "${VERDACCIO_USER}" -c \
  "verdaccio --config ${VERDACCIO_CONFIG} --listen http://0.0.0.0:${LISTEN_PORT}"
