<?php

/**
 * Tag de apertura de PHP obligatorio para archivos .php
 * 
 * NOTA: No incluimos tag de cierre ?> intencionalmente.
 * WordPress y PSR-2 recomiendan omitir ?> en archivos que contienen solo PHP
 * para evitar salida accidental de whitespace/newlines que puede corromper
 * headers HTTP o generar errores "Cannot modify header information".
 */

/**
 * ARCHIVO DE CONFIGURACIÓN PRINCIPAL DE WORDPRESS
 * 
 * El archivo wp-config.php es el archivo de configuración principal 
 * de WordPress que contiene las constantes y variables necesarias 
 * para establecer la conexión con la base de datos, configurar la seguridad,
 * y definir comportamientos específicos de la instalación.
 */

/**
 * CONFIGURACIÓN DE BASE DE DATOS
 * 
 * Estas constantes definen los parámetros de conexión a MySQL/MariaDB.
 * Los valores 'placeholder_here' son reemplazados dinámicamente por 
 * script.sh usando sed durante la inicialización del contenedor Docker.
 * 
 * El flujo es: docker-compose → variables de entorno → script.sh → wp-config.php
 */
// ** Configuración básica de WordPress ** //
define('DB_NAME', 'database_name_here');
define('DB_USER', 'username_here');
define('DB_PASSWORD', 'password_here');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

/**
 * CLAVES CRIPTOGRÁFICAS DE SEGURIDAD
 * 
 * WordPress usa estas 8 constantes para generar hashes seguros en:
 * - Cookies de autenticación (sesiones de usuario)
 * - Tokens NONCE (protección CSRF)
 * - Verificación de integridad de datos
 * 
 * AUTH/SECURE_AUTH/LOGGED_IN_KEY: claves para diferentes tipos de cookies
 * *_SALT: sales criptográficas que se combinan con las claves para aumentar entropía
 * 
 * IMPORTANTE: Usar valores aleatorios de 64+ caracteres. Si cambias estas claves,
 * todos los usuarios perderán sus sesiones activas.
 * 
 * Generadas desde: https://api.wordpress.org/secret-key/1.1/salt/
 */
define('AUTH_KEY',         'z2iGCA#k7QCkcPoc-Kl~h2o]U$?cQtoH~]PYeg-F3pJeOJ||C:j*qW5os,cE3Gm`');
define('SECURE_AUTH_KEY',  'GN#ba%kh,n,wr$BlC2N-[i^yEX9aIA9~b >#/Gx5`Oy?pdSc)Q TKsO.sPV;]~nD');
define('LOGGED_IN_KEY',    '$6 9F{WFd;]wFIB[_qq-lPQRWq{kdC]Cc@q#u-xkw&~|];5pb94&mG=|Y3^.9}p_');
define('NONCE_KEY',        '=mhk!/AtI,#E.#wF;8!g8=-3SU?D3A9|<UND l_K)BpTxMj:NnZy^yr>kT)m=Qh+');
define('AUTH_SALT',        'e-t*U5):keq<^6pC*6<C3T@PCs+%2j(9QW!U=JLk3.>+Yp9_pf+/EayCp-SlT9KR');
define('SECURE_AUTH_SALT', '!U++#qCt59OU?p3My9I+Z[NEpOTgqxl1A-.)xU])E^Gfw~hBK+n^9=],@!lE3y2!');
define('LOGGED_IN_SALT',   'w<*T*njS[E2t:fdf)F3<B5v$l`}_nJS&p]1++=B2x*O+u+r;|1ja}~/}[4blW?,=');
define('NONCE_SALT',       '[MU>|HQim/Zu}TuhU p9gLw!+X/o!P}NOWYhX2aJm</~|rFmb{8xX&-y1e RS#Vm');

/**
 * PREFIJO DE TABLAS DE BASE DE DATOS
 * 
 * Variable (no constante) que define el prefijo de todas las tablas de WordPress 
 * en la base de datos. Ejemplos: wp_posts, wp_users, wp_options.
 * 
 * Permite múltiples instalaciones de WordPress en la misma base de datos 
 * usando prefijos diferentes (wp_, blog1_, site2_, etc.).
 * 
 * Para verificar las tablas creadas:
 * docker exec -it mariadb sh
 * mariadb -u root -p
 * USE nombre_base_datos;
 * SHOW TABLES;
 */
$table_prefix = 'wp_';

/**
 * MODO DEBUG DE WORDPRESS
 * 
 * Controla si WordPress muestra errores PHP, warnings y notices en pantalla.
 * 
 * false (producción): errores solo en logs
 * true (desarrollo): errores visibles en navegador
 * 
 * SEGURIDAD: Nunca usar true en producción ya que expone información
 * sensible sobre rutas del servidor, estructura de archivos y errores internos.
 */
define('WP_DEBUG', false);

/**
 * DEFINICIÓN DE RUTA ABSOLUTA DE WORDPRESS
 * 
 * ABSPATH define la ruta raíz de la instalación de WordPress.
 * __FILE__ contiene la ruta completa de este archivo wp-config.php
 * dirname(__FILE__) extrae solo el directorio padre
 * 
 * Ejemplo: si wp-config.php está en /var/www/html/wp-config.php
 * entonces ABSPATH será /var/www/html/
 * 
 * Esta constante se usa para construir rutas seguras a otros archivos de WP.
 */
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

/**
 * BOOTSTRAP DE WORDPRESS
 * 
 * require_once es una función PHP que incluye un archivo una sola vez.
 * El operador "." concatena strings en PHP (equivalente a strcat en C).
 * 
 * wp-settings.php es el bootstrap de WordPress que:
 * - Carga todas las clases y funciones del core
 * - Establece la conexión a la base de datos usando las constantes DB_*
 * - Inicializa hooks, filtros, temas y plugins
 * - Prepara el entorno completo de WordPress
 * 
 * Sin esta línea, WordPress no arranca (solo tendríamos configuración sin software).
 */
require_once(ABSPATH . 'wp-settings.php');
