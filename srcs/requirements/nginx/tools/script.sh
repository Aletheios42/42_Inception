#!/bin/sh

## nginx carga su configuración desde archivos estáticos por defecto.
## Para configuraciones dinámicas (como certificados variables) es necesario un script.
## En entornos Docker, nginx debe ejecutarse en primer plano para que Docker gestione el proceso correctamente.

CERTS_CRT=${CERTS_CRT:-/etc/ssl/certs/nginx-selfsigned.crt}
## Variable CERTS_: ruta al certificado TLS.
## Si no está definida en entorno, toma como valor por defecto el certificado autofirmado estándar.
DOMAIN_NAME=${DOMAIN_NAME:-localhost}
## Variable DOMAIN_NAME: nombre común para el certificado TLS.
## Por defecto 'localhost' si no está definida externamente.

# Generar certificado autofirmado con openssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out "$CERTS_CRT" \
  -subj "/C=MO/L=KH/O=1337/OU=student/CN=$DOMAIN_NAME"
## Opciones:
## -x509: genera certificado autofirmado (no CSR).
## -nodes: sin cifrar la clave privada (sin password).
## -days 365: válido por un año.
## -newkey rsa:2048: crea nueva clave RSA 2048 bits.
## -keyout: archivo de clave privada.
## -out: archivo del certificado (variable CERTS_).
## -subj: campos del certificado (distinguished name), con CN usando DOMAIN_NAME.

# Validar configuración nginx antes de iniciar
nginx -t
## Testea la configuración (sintaxis y archivos) sin iniciar el servidor.
## Retorna error si la configuración es inválida, evitando fallos en producción.

# Ejecutar nginx en primer plano para Docker
nginx -g "daemon off;"
## Ejecuta nginx en modo no daemonizado (foreground).
## Es imprescindible para contenedores Docker para mantener el proceso principal activo.
