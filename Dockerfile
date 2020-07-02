FROM debian:buster

RUN	apt-get update \
	&& apt-get upgrade \
	&& apt-get install -y nginx libnginx-mod-http-perl mariadb-server openssl wget\
	php7.3-cli php7.3-fpm php7.3-mysql php7.3-json php7.3-opcache php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl

RUN	cd /tmp \
	&& wget https://wordpress.org/latest.tar.gz \
	&& wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
	&& tar xf latest.tar.gz && mkdir -p /var/www/wp && mv /tmp/wordpress/* /var/www/wp \
	&& tar xf phpMyAdmin-5.0.2-all-languages.tar.gz && mkdir -p /var/www/wp/phpmyadmin \
	&& mv /tmp/phpMyAdmin-5.0.2-all-languages/* /var/www/wp/phpmyadmin \
	&& chown -R www-data: /var/www/wp
RUN	mkdir /var/www/wp/index && touch /var/www/wp/index/example.txt

COPY srcs/init.sql /tmp
RUN	service mysql start && mysql < /tmp/init.sql

RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=IDF/O=42/CN=localhost" \
	-addext "subjectAltName=DNS:localhost" -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt

COPY srcs/wp /etc/nginx/sites-available
RUN	ln -s /etc/nginx/sites-available/wp /etc/nginx/sites-enabled && rm -f /etc/nginx/sites-enabled/default

RUN	ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

ENV	AUTOINDEX 'on'
RUN sed -i "16iperl_set \$index 'sub {return $ENV{\"AUTOINDEX\"};}';" /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

ENTRYPOINT service php7.3-fpm start && service mysql start && nginx -g 'daemon off;'