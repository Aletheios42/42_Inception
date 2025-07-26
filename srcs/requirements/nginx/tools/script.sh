#!/bin/sh

CERTS_=${CERTS_:-/etc/ssl/certs/nginx-selfsigned.crt}
DOMAIN_NAME=${DOMAIN_NAME:-localhost}

# Generar certificado autofirmado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out "$CERTS_" \
  -subj "/C=MO/L=KH/O=1337/OU=student/CN=$DOMAIN_NAME"


# Validar configuración antes de arrancar
nginx -t

# Ejecutar nginx en primer plano
nginx -g "daemon off;"
