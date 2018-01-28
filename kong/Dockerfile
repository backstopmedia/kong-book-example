FROM alpine:3.6

ENV KONG_VERSION 0.12.1
ENV KONG_SHA256 9f699e20e7d3aa6906b14d6b52cae9996995d595d646f9b10ce09c61d91a4257

RUN apk update \
    && apk add git \
    && apk add musl-dev \
    && apk add gcc \
    && apk add pcre-dev \
    && apk add --virtual .build-deps wget tar ca-certificates \
    && apk add libgcc openssl pcre perl \
    && wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
    && echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
    && tar -xzf kong.tar.gz -C /tmp \
    && rm -f kong.tar.gz \
    && cp -R /tmp/usr / \
    && rm -rf /tmp/usr \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]
