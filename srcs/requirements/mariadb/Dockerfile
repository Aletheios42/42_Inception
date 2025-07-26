FROM alpine:3.19

# Instalar mariadb y bash (opcional para script.sh)
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Crear directorios necesarios
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld


RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql

# Copiar archivos de configuración y script
COPY ./conf/50-server.cnf /etc/my.cnf.d/50-server.cnf
COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

# Exponer el puerto por si lo usas en bridge
EXPOSE 3306

# Entrypoint
CMD ["/script.sh"]

