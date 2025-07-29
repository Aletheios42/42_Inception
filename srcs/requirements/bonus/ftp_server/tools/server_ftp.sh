#!/bin/sh

if [ ! -f "/etc/vsftpd/vsftpd.conf.bak" ]; then

    mkdir -p /var/www/html

    cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
    mv /tmp/vsftpd.conf /etc/vsftpd/vsftpd.conf

    # Añadir usuario sin contraseña, y cambiarla con passwd
    adduser -D $FTP_USR
    echo "$FTP_USR:$FTP_PASSWD" | chpasswd

    chown -R $FTP_USR:$FTP_USR /var/www/html

    echo $FTP_USR >> /etc/vsftpd.userlist
fi

echo "FTP started on :21"
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
