map $http_accept_language $accept_language {
    ~*^en-US en-US;
    ~*^es es;
}

server {
        listen 443 ssl;
        listen [::]:443 ssl;
        include snippets/self-signed.conf;
        include snippets/ssl-params.conf;

        error_log syslog:server=127.0.0.1,tag=nginx_error_client;
        access_log syslog:server=127.0.0.1,tag=nginx_access_client;
        
        root /var/www/html/authenticationappui;
        index index.php index.html index.htm index.nginx-debian.html;

        if ($accept_language ~ "^$") {
        set $accept_language "en-US";
        }

        rewrite ^/$ ./$accept_language permanent;

        server_name greenradius www.greenradius;
        location / {
           try_files $uri $uri/ /index.html;
        }

        location ~ ^/(en-US|es) {
        try_files $uri /$1/index.html?$args;
        }
}

server {
    listen 80;
    listen [::]:80;

    server_name greenradius www.greenradius;

    return 302 https://$server_name$request_uri;
}
