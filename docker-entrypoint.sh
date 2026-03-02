#!/bin/sh
set -e

VERDACCIO_STORAGE="/verdaccio/storage"
VERDACCIO_CONFIG="/verdaccio/conf/config.yaml"
LISTEN_PORT="${PORT:-4873}"

# Ensure storage directory exists and is writable.
# Required when using mounted volumes (e.g. Railway, Docker Compose)
# that default to root ownership.
mkdir -p "${VERDACCIO_STORAGE}"

# Start Verdaccio
exec verdaccio --config "${VERDACCIO_CONFIG}" --listen "http://0.0.0.0:${LISTEN_PORT}"
