#!/bin/bash

exec 1> >(logger -s -t $(basename $0)) 2>&1
source /opt/grs/greenradius/grs_fido2_authenticator/config.txt
source /opt/grs/greenradius/grs_fido2_authenticator/fido2_config.txt
php /var/www/html/authenticatorapp/artisan config:clear
php /var/www/html/authenticatorapp/artisan cache:clear
php /var/www/html/authenticatorapp/artisan migrate
php /var/www/html/authenticatorapp/artisan add:api-user --username=$GRVA_CLIENT_BASIC_AUTH_USERNAME --password=$GRVA_CLIENT_BASIC_AUTH_PASSWORD
php /var/www/html/authenticatorapp/artisan db:seed
php /var/www/html/authenticatorapp/artisan add:app-configuration --category="FIDO2" --key="timeout" --value=$timeout
php /var/www/html/authenticatorapp/artisan add:app-configuration --category="FIDO2" --key="user_verification" --value=$user_verification
php /var/www/html/authenticatorapp/artisan add:app-configuration --category="FIDO2" --key="auto_provisioning" --value=$auto_provisioning
php /var/www/html/authenticatorapp/artisan add:app-configuration --category="APPLICATION" --key="RELYING_PARTY" --value=$DOMAIN
php /var/www/html/authenticatorapp/artisan add:app-configuration --category="FIDO2" --key="cache_server_host" --value=$cache_server_host
php /var/www/html/authenticatorapp/artisan update:echo-server --host=$cache_server_host --password="$cache_server_password"
sed -i "s/EXTERNAL_REDIS_HOST\=.*\$/EXTERNAL_REDIS_HOST\=$cache_server_host/" "/var/www/html/authenticatorapp/.env"
sed -i "s/EXTERNAL_REDIS_PASSWORD\=.*\$/EXTERNAL_REDIS_PASSWORD\=$cache_server_password/" "/var/www/html/authenticatorapp/.env"
php /var/www/html/authenticatorapp/artisan config:clear
php /var/www/html/authenticatorapp/artisan cache:clear
supervisorctl restart all