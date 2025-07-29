#!/bin/sh
set -eux

# Leer secrets desde archivos montados por Docker
DB_NAME=${DB_NAME:-wordpress}
DB_USER=${DB_USER:-wp_user}
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"


# Inicializar base de datos si no existe
if [ ! -d /var/lib/mysql/mysql ]; then
  mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# Crear script de inicialización SQL
cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE USER IF NOT EXISTS '$DB_USER'@'wordpress.srcs_wp_net' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE USER IF NOT EXISTS '$DB_USER'@'172.18.0.%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'wordpress.srcs_wp_net';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'172.18.0.%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

# Ejecutar el bootstrap
mysqld --user=mysql --bootstrap < /tmp/init.sql

# Limpiar archivo temporal
rm -f /tmp/init.sql

# Lanzar el servidor
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306 --socket=/run/mysqld/mysqld.sock --log-error=/var/log/mysql/error.log --skip-networking=0
