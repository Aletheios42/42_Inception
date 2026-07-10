#!/bin/bash
set -e

DATA_DIR=/var/lib/mysql

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "${DATA_DIR}/${MYSQL_DATABASE}" ]; then
    if [ ! -d "${DATA_DIR}/mysql" ]; then
        mysql_install_db --user=mysql --datadir="${DATA_DIR}" --skip-test-db
    fi

    DB_PASSWORD=$(cat /run/secrets/db_password)
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

    mysqld --user=mysql --skip-networking &
    TMP_PID=$!

    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}
            CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
            IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
	EOSQL

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "${TMP_PID}" 2>/dev/null || true
fi

exec "$@"