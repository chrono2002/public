
server {
    server_name test5.ru www.test5.ru;
    listen       95.168.183.91:80;

    location / {
	access_log /var/log/nginx/test5.ru.log main;
	root /www/test5.ru;
	index index.php index.html;
    }

    # -- PHP
    location ~ ^/(.*\.php)$ {
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME /www/test5.ru/$1;
        fastcgi_param DOCUMENT_ROOT /www/test5.ru;
    
        fastcgi_pass unix:/tmp/php-fpm.sock;
    }
}
