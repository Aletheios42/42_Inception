#!/bin/bash
set -e

WP_DIR=/var/www/html

mkdir -p /var/run/vsftpd/empty

if ! id "${FTP_USER}" >/dev/null 2>&1; then
    useradd -M -d "${WP_DIR}" -s /bin/bash "${FTP_USER}"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

for _ in $(seq 1 60); do
    [ -f "${WP_DIR}/wp-login.php" ] && break
    sleep 2
done
chown -R "${FTP_USER}:www-data" "${WP_DIR}"
chmod -R g+w "${WP_DIR}"

exec "$@"