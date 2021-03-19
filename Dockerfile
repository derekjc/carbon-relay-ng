FROM golang:1.15-alpine as builder

ENV CRNG_VERSION=v0.13.0
ENV GOPATH=/opt/go

RUN \
  apk update  --no-cache && \
  apk upgrade --no-cache && \
  apk add g++ git make musl-dev cairo-dev

WORKDIR ${GOPATH}

RUN \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/grafana/carbon-relay-ng.git

WORKDIR ${GOPATH}/carbon-relay-ng

RUN \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get github.com/shuLhan/go-bindata/cmd/go-bindata && \
  git checkout "tags/${CRNG_VERSION}" 2> /dev/null ; \
  version=${CRNG_VERSION} && \
  echo "build version: ${version}" && \
  make && \
  mv carbon-relay-ng /tmp/carbon-relay-ng

# ------------------------------ RUN IMAGE --------------------------------------
FROM alpine:3.13.2

LABEL org.opencontainers.image.source https://github.com/derekjc/carbon-relay-ng

COPY --from=builder /tmp/carbon-relay-ng /usr/bin/carbon-relay-ng

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
    mkdir -p \
        /var/spool/carbon-relay-ng && \
    chown -R carbon:carbon /var/spool/carbon-relay-ng && \
    rm -rf \
        /tmp/* \
        /var/cache/apk/*
COPY carbon-relay-ng.ini /etc/carbon-relay-ng/
COPY entrypoint.sh   /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 2003 8081

ENTRYPOINT ["/entrypoint.sh"]
