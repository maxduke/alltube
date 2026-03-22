FROM php:7.4-apache

RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries \
    && apt-get update && apt-get install -y --no-install-recommends --fix-missing \
        libicu-dev \
        xz-utils \
        git \
        python3 \
        python3-pip \
        libgmp-dev \
        unzip \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install intl gmp

RUN a2enmod rewrite

RUN python3 -m pip install yt-dlp

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY resources/php.ini /usr/local/etc/php/
COPY . /var/www/html/

WORKDIR /var/www/html/
RUN composer check-platform-reqs --no-dev \
    && composer install --prefer-dist --no-progress --no-dev --optimize-autoloader

RUN mkdir -p /var/www/html/templates_c/ \
    && chown -R www-data:www-data /var/www/html/ \
    && chmod -R 770 /var/www/html/templates_c/

ENV CONVERT=1
