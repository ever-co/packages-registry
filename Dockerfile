FROM verdaccio/verdaccio:6

LABEL maintainer="Ever Co. LTD <ever@ever.co>"
LABEL description="Verdaccio npm registry proxy with Railway volume support"
LABEL org.opencontainers.image.source="https://github.com/ever-co/verdaccio"
LABEL org.opencontainers.image.vendor="Ever Co. LTD"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

USER root

COPY config.yaml /verdaccio/conf/config.yaml
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE ${PORT:-4873}

ENTRYPOINT ["docker-entrypoint.sh"]
