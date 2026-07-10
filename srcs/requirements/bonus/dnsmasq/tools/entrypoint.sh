#!/bin/bash
set -e

envsubst '${DOMAIN_NAME}' \
    < /etc/dnsmasq/dnsmasq.conf.template \
    > /etc/dnsmasq/dnsmasq.conf

exec "$@"