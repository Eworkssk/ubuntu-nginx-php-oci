FROM ubuntu:20.04

# Copy clean script
COPY scripts/apt-clean.sh /bin/apt-clean
RUN chmod 755 /bin/apt-clean

# Versions
ENV NGINX_VERSION=1.18.* \
    SUPERVISOR_VERSION=4.1.* \
    PHP_VERSION=7.4 \
    PHP_REDIS_VERSION=5.3.* \
    IMAGICK_VERSION=8:6.9.10.* \
    PHP_IMAGICK_VERSION=3.4.* \
    GHOSTSCRIPT_VERSION=9.50* \
    POPPLER_UTILS_VERSION=0.86.* \
    LOGROTATE_VERSION=3.14.*

ARG DEBIAN_FRONTEND=noninteractive

# Install apt-utils
RUN apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y apt-utils && apt-clean

# Install required/helper packages
RUN apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    dirmngr \
    g++ \
    ghostscript=${GHOSTSCRIPT_VERSION} \
    git \
    gnupg \
    imagemagick=${IMAGICK_VERSION} \
    jq \
    libedit-dev \
    libfcgi-bin \
    libfcgi0ldbl \
    libfreetype-dev \
    libaio-dev \
    libicu-dev \
    libmcrypt-dev \
    logrotate=${LOGROTATE_VERSION} \
    nano \
    nginx-full=${NGINX_VERSION} \
    poppler-utils=${POPPLER_UTILS_VERSION} \
    software-properties-common \
    ssh \
    supervisor=${SUPERVISOR_VERSION} \
    unzip \
    zip \
    xz-utils && \
    apt-clean

# Install PHP
RUN add-apt-repository ppa:ondrej/php -y && apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
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
    php-imagick=${PHP_IMAGICK_VERSION} \
    php-pear \
    php-redis=${PHP_REDIS_VERSION} \
    php-ssh2 \
    php-uploadprogress && \
    apt-clean

# Data volume group
RUN groupadd -g 1212 data && \
    usermod -a -G data www-data

EXPOSE 80
EXPOSE 443

# Symlinks and directories
RUN ln -s /usr/bin/pdftotext /usr/local/bin/pdftotext && chmod 755 /usr/local/bin/pdftotext
RUN mkdir -p /run/php

# Branding and homepage
COPY homepage /var/www/html

# ENV variables
ENV ENVIRONMENT=development \
    DOCKER_IMAGE=eworkssk/ubuntu-nginx-php-oci \
    DOCKER_IMAGE_EDITION=base \
    DOCKER_IMAGE_VERSION=base-2.0.1 \
    PHP_FPM_POOL_LISTEN=/run/php/php${PHP_VERSION}-fpm.sock \
    PHP_FPM_POOL_STATUS=/status \
    HEALTHCHECK_LOG_FILE=/var/log/healthcheck.log

# Configuration files
COPY configs/nginx/default.conf /etc/nginx/sites-enabled/default
COPY configs/php/pool.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck
COPY healthcheck/nginx.sh /usr/local/bin/nginx-healthcheck
COPY healthcheck/php-fpm.sh /usr/local/bin/php-fpm-healthcheck

HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 CMD healthcheck

COPY configs/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]