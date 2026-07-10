#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out  /etc/nginx/ssl/server.crt \
        -subj "/C=ES/L=Madrid/O=42/OU=inception/CN=${DOMAIN_NAME:-localhost}"
fi

envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/templates/nginx.conf.template \
    > /etc/nginx/nginx.conf

envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/templates/homepage.html.template \
    > /etc/nginx/homepage/index.html

exec "$@"