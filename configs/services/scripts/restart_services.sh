#!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1
service php8.1-fpm restart
service nginx restart
service supervisor start
service cron restart
/etc/init.d/redis-server start
crontab /etc/cron.d/run_scheduler_cronjob