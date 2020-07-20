FROM debian:buster

RUN	apt-get update -y\
	&& apt-get upgrade -y\
	&& apt-get install -y nginx mariadb-server openssl wget\
	php7.3-cli php7.3-fpm php7.3-mysql php7.3-json php7.3-opcache php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl

COPY srcs/phpMyAdmin-5.0.2-all-languages.tar.gz /tmp
COPY srcs/wordpress-5.4.2.tar.gz /tmp
RUN	cd /tmp \
	&& tar xf wordpress-5.4.2.tar.gz && mkdir -p /var/www/wp && mv /tmp/wordpress/* /var/www/wp \
	&& tar xf phpMyAdmin-5.0.2-all-languages.tar.gz && mkdir -p /var/www/wp/phpmyadmin \
	&& mv /tmp/phpMyAdmin-5.0.2-all-languages/* /var/www/wp/phpmyadmin \
	&& chown -R www-data: /var/www/wp
RUN	mkdir /var/www/wp/index && touch /var/www/wp/index/example.txt

RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=IDF/O=42/CN=localhost" \
	-addext "subjectAltName=DNS:localhost" -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt

COPY srcs/init.sql /tmp
RUN	service mysql start && mysql < /tmp/init.sql

COPY srcs/wp /etc/nginx/sites-available
RUN	ln -s /etc/nginx/sites-available/wp /etc/nginx/sites-enabled && rm -f /etc/nginx/sites-enabled/default

ENV	AUTOINDEX 1

COPY srcs/init_index.sh /tmp
RUN	chmod o+x /tmp/init_index.sh

EXPOSE 80
EXPOSE 443

CMD bash /tmp/init_index.sh; service php7.3-fpm start && service mysql start && nginx -g 'daemon off;'