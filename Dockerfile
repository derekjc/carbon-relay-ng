FROM raintank/carbon-relay-ng:0.13.0

LABEL org.opencontainers.image.source https://github.com/derekjc/carbon-relay-ng

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual .build-deps \
        shadow \
        tzdata \
        libc6-compat \
        ca-certificates \
        su-exec \
        tini \
    && mkdir /etc/carbon-relay-ng \
    && /usr/sbin/useradd \
        --system \
        -U \
        -s /bin/false \
        -c "User for Graphite daemon" \
        carbon && \
    mkdir \
        /var/spool/carbon-relay-ng && \
    chown -R carbon:carbon /var/spool/carbon-relay-ng && \
    rm -rf \
        /tmp/* \
        /var/cache/apk/*
COPY carbon-relay-ng.conf /etc/carbon-relay-ng/
COPY entrypoint.sh   /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 2003 2004 2013 8081

ENTRYPOINT ["/entrypoint.sh"]