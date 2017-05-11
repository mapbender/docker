FROM nginx

RUN apt-get update -y
RUN apt-get upgrade -y --force-yes

RUN apt-get install curl wget git php php-xml php-mbstring php-mysql php-bz2 php-curl php-gd php-intl php-mcrypt php-memcache php-sqlite3 php-pgsql sqlite3 php-fpm gdal-bin net-tools python gdal-bin python-pip zip -y
RUN curl -sL https://deb.nodesource.com/setup_7.x
RUN apt-get install -y nodejs
#RUN npm install npm --global
RUN mkdir mapbender
RUN git clone -b release/3.0.6 https://github.com/mapbender/mapbender-starter.git mapbender
RUN cd mapbender; git submodule update --init --recursive
RUN cp mapbender/application/app/config/parameters.yml.dist mapbender/application/app/config/parameters.yml
RUN curl -sS https://getcomposer.org/installer | php
RUN ./composer.phar install -d mapbender/application/
RUN mapbender/application/app/console doctrine:database:create
RUN mapbender/application/app/console doctrine:schema:create
RUN mapbender/application/app/console assets:install mapbender/application/web/
RUN mapbender/application/app/console fom:user:resetroot --username=root --password=root --email=root@root.de -n
RUN mapbender/application/app/console doctrine:fixtures:load --fixtures=mapbender/application/mapbender/src/Mapbender/CoreBundle/DataFixtures/ORM/Epsg/ --append
RUN rm -rf mapbender/application/app/cache/* mapbender/application/app/logs/*
RUN chown -R www-data:www-data mapbender
RUN chmod -R ugo+r mapbender
RUN chmod -R ug+w mapbender/application/web
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php/7.0/fpm/php-fpm.conf
RUN sed -e 's/;listen\.owner/listen.owner/' -i /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -e 's/;listen\.group/listen.group/' -i /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -e 's/listen = .run.php.php7.0-fpm.sock/listen = 127.0.0.1:9000/' -i /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -e 's/;catch_workers_output/catch_workers_output/' -i /etc/php/7.0/fpm/pool.d/www.conf

COPY default.conf /etc/nginx/conf.d/default.conf
RUN service php7.0-fpm start
CMD /etc/init.d/php7.0-fpm restart; nginx -g 'daemon off;'