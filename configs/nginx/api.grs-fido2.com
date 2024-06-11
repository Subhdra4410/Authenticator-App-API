server {
        listen 8443 ssl;
        listen [::]:8443 ssl;
        include snippets/self-signed.conf;
        include snippets/ssl-params.conf;
        
        error_log syslog:server=127.0.0.1,tag=nginx_error_client;
        access_log syslog:server=127.0.0.1,tag=nginx_access_client;

       # root /var/www/api.grs-fido2/html;
        root /var/www/html/authenticatorapp/public;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name greenradius www.greenradius;

  location / {
             #   try_files $uri $uri/ =404;
             #try_files $uri $uri/ /index.php$is_args$args;
              try_files $uri $uri/ /index.php?$query_string;
        }


        #root /var/www/html/authenticatorapp/public;

        # Add index.php to the list if you are using PHP
        #index index.php index.html index.htm index.nginx-debian.html;
        # server_name -;

        #location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ /index.php?$query_string;
        #}

                # pass PHP scripts to FastCGI server
        #
                 location ~ \.php$ {
             #try_files $uri =404;
             #fastcgi_split_path_info ^(.+\.php)(/.+)$;
             fastcgi_pass unix:/run/php/php8.1-fpm.sock;
             #fastcgi_index index.php;
             fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
             include fastcgi_params;
     }
}
