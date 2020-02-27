FROM ubuntu:18.04

ENV NGINX_VERSION=1.14.* \
    SUPERVISOR_VERSION=3.3.* \
    PHP_VERSION=7.3 \
    ORACLE_VERSION=19.3 \
    ORACLE_VERSION_PATH="19_3" \
    OCI_VERSION=2.2.0

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
    php-redis=5.1\* \
    imagemagick=8:6.9.7.4\* \
    php-imagick=3.4.4\* \
    ghostscript=9.26\* \
    poppler-utils=0.62\*

# FFMPEG
ENV FFMPEG_VERSION=7:3.4.6\*
RUN apt-get update -y && apt-get install -y ffmpeg=${FFMPEG_VERSION}

# Instantclient
COPY ./instantclient/instantclient.zip /instantclient.zip
COPY ./instantclient/instantclient_sdk.zip /instantclient_sdk.zip

RUN unzip instantclient.zip -d /usr/local && \
    unzip instantclient_sdk.zip -d /usr/local && \
    ln -s /usr/local/instantclient_${ORACLE_VERSION_PATH} /usr/local/instantclient && \
    ln -s /usr/local/instantclient/lib* /usr/lib && \
    rm /instantclient.zip && rm /instantclient_sdk.zip

# Install OCI
RUN pecl channel-update pecl.php.net && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'umask 002' >> /root/.bashrc && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8-${OCI_VERSION} && \
    echo "extension=oci8.so" > /etc/php/${PHP_VERSION}/fpm/conf.d/php-oci8.ini && \
    echo "extension=oci8.so" > /etc/php/${PHP_VERSION}/cli/conf.d/php-oci8.ini

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