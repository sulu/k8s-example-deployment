FROM php:7.4-apache AS php

WORKDIR /var/www/html

# install packages
# inkscape is recommended for handling svg files with imagemagick
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libmagickwand-dev \
    inkscape \
    git \
    unzip \
    libzip-dev

# install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
        intl \
        pdo \
        pdo_mysql \
        zip

RUN pecl install redis apcu imagick && docker-php-ext-enable redis apcu imagick

# apache extensions
RUN /usr/sbin/a2enmod rewrite && /usr/sbin/a2enmod headers && /usr/sbin/a2enmod expires

# install php dependencies in intermediate container
FROM php AS composer

COPY symfony.lock /var/www/html/
COPY composer.* /var/www/html/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer self-update --1
RUN composer install --no-interaction --no-cache --no-scripts --no-dev --prefer-dist --optimize-autoloader --apcu-autoloader

FROM php AS project

# copy project code and results from intermediate containers
COPY --from=composer /var/www/html/vendor/ /var/www/html/vendor/
COPY . /var/www/html/

# apache config
COPY ./deploy/config/apache.conf /etc/apache2/sites-available/000-default.conf
