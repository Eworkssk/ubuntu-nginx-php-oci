FROM ubuntu:18.04

ENV NGINX_VERSION=1.14.* \
    SUPERVISOR_VERSION=3.3.* \
    PHP_VERSION=7.3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt install --no-install-recommends --no-install-suggests -y apt-utils

# Install required software
RUN apt-get update -y && apt-get upgrade -y && apt-get install --no-install-recommends --no-install-suggests -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    git \
    ssh \
    curl \
    gnupg2 \
    dirmngr \
    g++ \
    jq \
    libedit-dev \
    libfcgi0ldbl \
    libfreetype6-dev \
    libaio-dev \
    libicu-dev \
    libmcrypt-dev \
    libpq-dev \
    libssh2-1 \
    libssh2-1-dev \
    supervisor=${SUPERVISOR_VERSION} \
    unzip \
    zip \
    tar \
    nano

# Custom apt repositories
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update -y

# Install nginx
RUN apt-get install -y nginx-full=${NGINX_VERSION}

# Install PHP and stuff
RUN apt-get update -y && apt-get install -y php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php-pear \
    php-xml \
    imagemagick=8:6.9.7.4\* \
    php-imagick=3.4.4\* \
    ghostscript=9.26\* \
    poppler-utils=0.62\*

RUN apt install -y php-ssh2

EXPOSE 80
EXPOSE 443

VOLUME /var/log
RUN mkdir -p /var/log/nginx && mkdir -p /var/log/supervisor && chmod -R 664 /var/log

VOLUME /var/www/cgi-bin
VOLUME /var/www/html

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./eworks-logo.png /var/www/html/eworks-logo.png
COPY ./index.html /var/www/html/index.html

RUN mkdir -p /var/run/php
RUN ln -s /usr/bin/pdftotext /usr/local/bin/pdftotext && chmod 755 /usr/local/bin/pdftotext

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]