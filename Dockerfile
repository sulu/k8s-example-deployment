# install php dependencies in intermediate container
FROM composer:latest AS composer

WORKDIR /var/www/html

RUN composer global require hirak/prestissimo --no-plugins --no-scripts

COPY composer.* /var/www/html/
RUN composer install --apcu-autoloader -o --no-dev --no-scripts --ignore-platform-reqs

# build actual application image
FROM php:7.4-apache

WORKDIR /var/www/html

# install packages
# inkscape is recommended for handling svg files with imagemagick
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libmagickwand-dev \
    inkscape

# install PHP extensions
RUN docker-php-ext-configure intl && docker-php-ext-install -j$(nproc) \
        intl \
        pdo \
        pdo_mysql

RUN pecl install redis apcu imagick && docker-php-ext-enable redis apcu imagick

# apache config
RUN /usr/sbin/a2enmod rewrite && /usr/sbin/a2enmod headers && /usr/sbin/a2enmod expires

# copy needed files from build containers
COPY --from=composer /var/www/html/vendor/ /var/www/html/vendor/

COPY . /var/www/html/

# php config
ADD ./deploy/config/php.ini /usr/local/etc/php/conf.d/custom.ini

# apache config
COPY ./deploy/config/apache.conf /etc/apache2/sites-available/000-default.conf
