#!/bin/sh

set -e

# Ruta a la configuración de WordPress
WP_CONFIG_PATH="/wp-config.php"
WP_HTML_DIR="/var/www/html"

# Variables de entorno para la configuración dinámica
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD_FILE="/run/secrets/db_password"
DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
DB_HOST=${DB_HOST}

# Verificar si WordPress ya está instalado en el volumen
if [ ! -f "${WP_HTML_DIR}/index.php" ]; then
    echo "WordPress no encontrado en el volumen. Descargando..."
    
    # Limpiar directorio por si hay archivos residuales
    rm -rf ${WP_HTML_DIR}/*
    
    # Descargar WordPress usando WP-CLI
    cd "${WP_HTML_DIR}"
    wp core download --allow-root
    
    echo "WordPress descargado correctamente."
fi

# Copiar el archivo de configuración base si no existe la configuración actual
if [ ! -f "${WP_HTML_DIR}/wp-config.php" ]; then
    echo "Configurando wp-config.php..."
    cp "${WP_CONFIG_PATH}" "${WP_HTML_DIR}/wp-config.php"
    
    # Reemplazar valores dinámicos en wp-config.php
    sed -i "s/database_name_here/${DB_NAME}/g" "${WP_HTML_DIR}/wp-config.php"
    sed -i "s/username_here/${DB_USER}/g" "${WP_HTML_DIR}/wp-config.php"
    sed -i "s/password_here/${DB_PASSWORD}/g" "${WP_HTML_DIR}/wp-config.php"
    sed -i "s/localhost/${DB_HOST}/g" "${WP_HTML_DIR}/wp-config.php"
fi

# Cambiar permisos para que el servidor web tenga acceso adecuado
chown -R nobody:nogroup "${WP_HTML_DIR}"

# Configurar PHP-FPM para escuchar en todas las interfaces
sed -i 's/listen = .*/listen = 0.0.0.0:9000/' /etc/php82/php-fpm.d/www.conf

# Configurar PHP-FPM para modo daemon off (importante para Docker)
sed -i 's/;daemonize = yes/daemonize = no/' /etc/php82/php-fpm.conf

# Función para verificar conexión con la base de datos
wait_for_database() {
    echo "Verificando conexión con base de datos..."
    while ! php -r "
    try {
        new PDO('mysql:host=${DB_HOST};dbname=${DB_NAME}', '${DB_USER}', '${DB_PASSWORD}');
        echo 'Base de datos disponible\n';
        exit(0);
    } catch (Exception \$e) {
        exit(1);
    }
    " 2>/dev/null; do
        echo "Base de datos no disponible, esperando..."
        sleep 3
    done
    echo "¡Base de datos disponible!"
}

# Función para instalar WordPress usando WP-CLI
install_wordpress() {
    cd /var/www/html || return 1

    # Verificar que los archivos core de WordPress existen
    if [ ! -f "index.php" ] || [ ! -f "wp-load.php" ]; then
        echo "ERROR: Archivos core de WordPress no encontrados"
        return 1
    fi

    echo "Verificando WP-CLI..."
    if ! wp --info --allow-root 2>/dev/null; then
        echo "ERROR: WP-CLI no funciona correctamente"
        return 1
    fi

    if ! wp core is-installed --allow-root 2>/dev/null; then
        echo "Instalando WordPress core..."
        wp core install \
            --url="${DOMAIN_NAME}" \
            --title="${WP_TITLE}" \
            --admin_user="${WP_ADMIN_USR}" \
            --admin_password="$(cat /run/secrets/wp_admin_password)" \
            --admin_email="${WP_ADMIN_EMAIL}" \
            --allow-root

        echo "Creando usuario adicional..."
        wp user create "${WP_USR}" "${WP_EMAIL}" \
            --user_pass="$(cat /run/secrets/wp_user_password)" \
            --role=author \
            --allow-root

        echo "¡WordPress instalado correctamente!"
    else
        echo "WordPress ya está instalado."
    fi
}

# Conecta con la base de datos
wait_for_database

# Ejecutar instalación de WordPress
install_wordpress

echo "WordPress configurado. Iniciando PHP-FPM en primer plano..."

# Iniciar PHP-FPM en primer plano (esto mantiene el contenedor vivo)
exec php-fpm82 --nodaemonize
