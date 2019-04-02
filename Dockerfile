FROM debian:9

RUN apt-get update -y
RUN apt-get upgrade -y --force-yes
RUN apt-get install apt-transport-https lsb-release ca-certificates wget -y
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt-get update -y
RUN apt-get install apache2 curl git openssl vim -y --allow-unauthenticated
RUN apt-get install php7.2 php7.2-common php7.2-gd php7.2-curl php7.2-cli php7.2-xml -y --allow-unauthenticated
RUN apt-get install sqlite3 php7.2-sqlite3 php7.2-intl openssl php7.2-zip php7.2-mbstring php7.2-bz2 -y --allow-unauthenticated
RUN apt-get install php7.2-fpm php7.2-pgsql php7.2-mysql -y --allow-unauthenticated

RUN git clone https://github.com/mapbender/mapbender-starter.git /var/www/mapbender
RUN cd /var/www/mapbender; ./bootstrap

RUN chown -R www-data:www-data /var/www/mapbender
RUN chmod -R ugo+r /var/www/mapbender
RUN chmod -R ug+w /var/www/mapbender/application/web/uploads
RUN chmod ug+w /var/www/mapbender/application/app/db/demo.sqlite
RUN chmod ug+x /var/www/mapbender/application/vendor/eslider/sasscb/dist/sassc

RUN a2enmod rewrite
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN rm /etc/apache2/sites-enabled/*

COPY ./default.conf /etc/apache2/sites-enabled/mapbender.conf

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]