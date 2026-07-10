#!/bin/bash
set -e

WP_DIR=/var/www/html

DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done

mkdir -p "${WP_DIR}"

if [ ! -f "${WP_DIR}/wp-settings.php" ]; then
    wp core download --path="${WP_DIR}" --allow-root
fi

if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    wp config create \
        --path="${WP_DIR}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
fi

wp config set WP_REDIS_HOST redis --path="${WP_DIR}" --allow-root
wp config set WP_REDIS_PORT 6379 --raw --path="${WP_DIR}" --allow-root
wp config set WP_CACHE_KEY_SALT "${DOMAIN_NAME}" --path="${WP_DIR}" --allow-root
wp config set WP_REDIS_CLIENT phpredis --path="${WP_DIR}" --allow-root

if ! wp core is-installed --path="${WP_DIR}" --allow-root 2>/dev/null; then
    wp core install \
        --path="${WP_DIR}" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USR}" \
        "${WP_EMAIL}" \
        --path="${WP_DIR}" \
        --role=author \
        --user_pass="${USER_PASSWORD}" \
        --allow-root
fi

if ! wp plugin is-installed redis-cache --path="${WP_DIR}" --allow-root 2>/dev/null; then
    wp plugin install redis-cache --activate --path="${WP_DIR}" --allow-root
fi
wp redis enable --path="${WP_DIR}" --allow-root 2>/dev/null || true

exec "$@"