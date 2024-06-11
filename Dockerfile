# syntax=docker/dockerfile:1
FROM ubuntu:22.04
EXPOSE 443 80

RUN apt-get update -y && apt-get upgrade -y
RUN apt install nginx -y
COPY /configs/nginx/default /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default  /etc/nginx/sites-enabled/
RUN DEBIAN_FRONTEND=noninteractive TZ=Asia/Kolkata apt-get install php-fpm -y
RUN apt-get install php -y

RUN apt install openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip -y
RUN apt-get install vim -y
RUN apt-get install php-zip -y
RUN apt-get install systemd -y
RUN apt-get install net-tools -y
RUN apt-get update -y
RUN apt-get install php-gmp -y
RUN apt-get install supervisor -y
RUN apt-get install cron -y
RUN apt-get update -y
RUN apt-get install php-bcmath -y
WORKDIR /etc/
COPY ./configs/syslog/rsyslog_8.32.0-1ubuntu4_amd64.deb /etc/rsyslog_8.32.0-1ubuntu4_amd64.deb
RUN apt-get update -y
RUN apt-get install libfastjson4 -y
RUN apt-get install libestr-dev -y
RUN dpkg -i rsyslog_8.32.0-1ubuntu4_amd64.deb
COPY ./configs/laravel/rsyslog.conf  /etc/rsyslog.conf
COPY ./configs/laravel/50-default.conf  /etc/rsyslog.d/
COPY ./configs/services/initCheckConfigurationUpdated.service /etc/systemd/system/initCheckConfigurationUpdated.service

WORKDIR /var/www/html
RUN mkdir temp
COPY ./authenticatorapp ./temp
RUN service php8.1-fpm start
RUN service nginx start
WORKDIR /var/www/html/temp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

RUN mv composer.phar /usr/local/bin/composer
COPY ./configs/laravel/.env  /var/www/html/temp/.env
RUN composer install
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan view:cache
RUN apt-get update -y
RUN apt-get install redis -y
RUN apt-get install php-redis -y
#RUN php artisan migrate
#RUN php artisan db:seed
RUN apt-get update -y
RUN apt-get -y install -qq curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN apt-get install nodejs -y
RUN npm install n -g
RUN npm install -g laravel-echo-server
COPY ./configs/fido2_config.txt /opt/grs/greenradius/grs_fido2_authenticator/fido2_config.txt
COPY ./configs/laravel/laravel-echo-server.json /var/www/html/temp/laravel-echo-server.json
COPY ./configs/laravel/laravel-echo-server-ssl.json /var/www/html/temp/laravel-echo-server-ssl.json
COPY ./configs/services/serviceCommands.sh /opt/serviceCommands.sh
COPY ./configs/services/scripts/  /opt/scripts/
COPY ./configs/UI_dist/authenticationappui /var/www/html/authenticationappui
COPY ./configs/config.txt /opt/grs/greenradius/grs_fido2_authenticator/config.txt
RUN apt-get install php-pgsql -y
WORKDIR /etc/nginx
RUN mkdir ssl
COPY /configs/ssl/greenradius_cert.pem ./ssl
COPY /configs/ssl/greenradius_key.pem ./ssl
COPY /configs/ssl/dhparam.pem ./ssl
COPY /configs/ssl/api.grs-fido2.com_ui_certificate.cer ./ssl
COPY /configs/ssl/self-signed.conf /etc/nginx/snippets
COPY /configs/ssl/ssl-params.conf /etc/nginx/snippets
WORKDIR /etc/nginx/sites-available
COPY /configs/nginx/api.grs-fido2.com /etc/nginx/sites-available/api.grs-fido2.com
COPY /configs/nginx/app.grs-fido2.com /etc/nginx/sites-available/app.grs-fido2.com
WORKDIR /etc/nginx
COPY /configs/nginx/nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /etc/nginx/sites-available/api.grs-fido2.com  /etc/nginx/sites-enabled/api.grs-fido2.com
RUN ln -sf /etc/nginx/sites-available/app.grs-fido2.com  /etc/nginx/sites-enabled/app.grs-fido2.com
RUN nginx -t 
COPY ./configs/supervisor/auth-request-expiry-worker.conf /etc/supervisor/conf.d
COPY ./configs/supervisor/laravel-echo-server-worker.conf /etc/supervisor/conf.d
COPY ./configs/supervisor/notify-grva-worker.conf /etc/supervisor/conf.d
COPY ./configs/supervisor/notify-auth-request-status-worker.conf /etc/supervisor/conf.d
COPY ./configs/supervisor/check_replication_info_worker.conf /etc/supervisor/conf.d
COPY ./configs/cron/run_scheduler_cronjob /etc/cron.d

WORKDIR /opt
RUN chmod 777 serviceCommands.sh
WORKDIR /var/www/html
RUN rm -rf /var/lib/apt/lists/*