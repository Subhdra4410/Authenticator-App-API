#!/bin/bash

exec 1> >(logger -s -t $(basename $0)) 2>&1
path="\/var\/log\/syslog"

if [ ! -d "/etc/redis/redis.conf" ]; then
    sed -i "s/logfile .*\$/logfile $path/" "/etc/redis/redis.conf"
else
    echo "redis.conf file not found"
fi

if [ ! -d "/etc/php/8.1/fpm/php-fpm.conf" ]; then
    sed -i "s/error_log \= .*\$/error_log \= $path/" "/etc/php/8.1/fpm/php-fpm.conf"
else
    echo "php-fpm.conf file not found"
fi

if [ ! -d "/etc/supervisor/supervisord.conf" ]; then
    sed -i "s/logfile\=.*\$/logfile\=$path/" "/etc/supervisor/supervisord.conf"
    sed -i "s/childlogdir\=.*\$/childlogdir\=\/var\/log/" "/etc/supervisor/supervisord.conf"
else
    echo "supervisord.conf file not found"
fi