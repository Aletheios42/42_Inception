# 42_Inception

#Paso 1: NGINX
docs: https://nginx.org/en/docs/
Tutorial: https://www.youtube.com/watch?v=7VAI73roXaY
            https://www.youtube.com/watch?v=Hfg7_y0fGTg
article: https://medium.com/@nomannayeem/mastering-nginx-a-beginner-friendly-guide-to-building-a-fast-secure-and-scalable-web-server-cb075b423298
-   Crea su Dockerfile con configuración mínima.
-   Monta los volúmenes necesarios (config + certificados).
-   Expón los puertos 443/80 según requiera el subject.
-   Verifica con un contenedor de prueba (curl, wget) que responde correctamente.

2. WordPress (frontend)
Requiere PHP y base de datos.

Usa volumen persistente para /var/www/html.

Configura conexión con MariaDB usando variables de entorno.

3. MariaDB (backend de WordPress)
Contenedor MySQL compatible.

Define volumen persistente para /var/lib/mysql.

Usa variables MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD.

4. phpMyAdmin (admin opcional para MariaDB)
Útil para validar que MariaDB funciona correctamente.

Configura acceso a través de NGINX.

5. Redis (caché de WordPress)
Mejora el rendimiento de WordPress.

Usa plugin de Redis Object Cache en WordPress.

Añade configuración mínima para conexión.

6. Adminer o herramienta equivalente (opcional)
Puede usarse en lugar de phpMyAdmin.

Útil si decides excluir phpMyAdmin.

7. FTP (opcional, por ejemplo vsftpd)
Requiere usuario/password configurado vía Dockerfile o .env.

Expón puerto 21.

Usa volumen compartido con WordPress.

8. Monitoring con Telegraf + InfluxDB + Grafana
Telegraf como agente.

InfluxDB como base de datos de métricas.

Grafana como dashboard web.

Expón puertos 3000 (Grafana) y otros según necesidad.

9. Backup (por ejemplo, script cron + rsync o volúmenes montados)
Programa tareas en contenedor dedicado.

Backup de DB y archivos de WordPress.
