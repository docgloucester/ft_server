FROM debian:buster

RUN	apt-get update \
	&& apt-get upgrade \
	&& apt-get install -y nginx mariadb-server openssl wget\
	php7.3-cli php7.3-fpm php7.3-mysql php7.3-json php7.3-opcache php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl

RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=IDF/O=42/CN=mydomain.com" \
	-addext "subjectAltName=DNS:mydomain.com" -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt

RUN	cd /tmp && wget https://wordpress.org/latest.tar.gz \
	&& tar xf latest.tar.gz && mkdir -p /var/www/wp && mv /tmp/wordpress/* /var/www/wp \
	&& chown -R www-data: /var/www/wp

COPY srcs/wp /etc/nginx/sites-available
RUN	ln -s /etc/nginx/sites-available/wp /etc/nginx/sites-enabled

RUN	ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443

CMD /bin/sh
#ENTRYPOINT nginx -g 'daemon off;'