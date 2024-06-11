#!/bin/bash

exec 1> >(logger -s -t $(basename $0)) 2>&1
if [ ! -d "/var/www/html/authenticatorapp" ]; then
    mkdir  /var/www/html/authenticatorapp
fi

if [ -d "/var/www/html/temp" ]; then
    cp -rf /var/www/html/temp/*  /var/www/html/authenticatorapp/
    cp -rf /var/www/html/temp/.env  /var/www/html/authenticatorapp/
    rm -rf /var/www/html/temp
fi
chmod -R 777 /var/www/html/authenticatorapp
chown -R root:root /var/www/html/authenticatorapp
chmod 744 /opt/scripts/check_configuration_updated.sh
chmod 777 /var/log/syslog
chmod 664 /etc/systemd/system/initCheckConfigurationUpdated.service
sed -i -e 's/\r$//' /opt/scripts/update_configurations.sh