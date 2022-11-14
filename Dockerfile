FROM ubuntu:22.04

# Copy clean script
COPY scripts/apt-clean.sh /bin/apt-clean
RUN chmod 755 /bin/apt-clean

# Versions
ENV NGINX_VERSION=1.18.* \
    SUPERVISOR_VERSION=4.2.* \
    PHP_VERSION=7.4 \
    IMAGICK_VERSION=8:6.9.11.* \
    ORACLE_INSTANTCLIENT_VERSION="21_8" \
    PHP_OCI_VERSION=2.2.0 \
    GHOSTSCRIPT_VERSION=9.55* \
    POPPLER_UTILS_VERSION=22.02.* \
    LOGROTATE_VERSION=3.19.* \
    LIBVIPS_VERSION=8.13.3

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
    tzdata \
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
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-ssh2 \
    php${PHP_VERSION}-uploadprogress \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php-pear && \
    apt-clean

# Copy Oracle Instantclient files
COPY instantclient/instantclient.zip /instantclient.zip
COPY instantclient/instantclient_sdk.zip /instantclient_sdk.zip

# Install Oracle Instantclient
RUN unzip instantclient.zip -d /usr/local && \
    unzip instantclient_sdk.zip -d /usr/local && \
    ln -s /usr/local/instantclient_${ORACLE_INSTANTCLIENT_VERSION} /usr/local/instantclient && \
    ln -s /usr/local/instantclient/lib* /usr/lib && \
    rm /instantclient.zip && rm /instantclient_sdk.zip

# Install PHP OCI8 extension
RUN pecl channel-update pecl.php.net && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'umask 002' >> /root/.bashrc && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8-${PHP_OCI_VERSION} && \
    echo "extension=oci8.so" > /etc/php/${PHP_VERSION}/fpm/conf.d/php-oci8.ini && \
    echo "extension=oci8.so" > /etc/php/${PHP_VERSION}/cli/conf.d/php-oci8.ini && \
    pecl clear-cache

# Install libvips
RUN apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
        wget build-essential pkg-config libglib2.0-dev libexpat1-dev liblcms2-dev libpoppler-glib-dev librsvg2-dev \
        libcairo2 libcairo2-dev libwebp-dev libtiff-dev libgif-dev libmagick++-dev=${IMAGICK_VERSION}\* && \
    wget https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.gz && \
    tar xf vips-${LIBVIPS_VERSION}.tar.gz && \
    cd vips-${LIBVIPS_VERSION} && \
    ./configure && \
    make -j8 && \
    make install && \
    ldconfig && \
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
    DOCKER_IMAGE_EDITION=default \
    DOCKER_IMAGE_VERSION=3.0.0 \
    PHP_FPM_POOL_LISTEN=/run/php/php${PHP_VERSION}-fpm.sock \
    PHP_FPM_POOL_STATUS=/status \
    HEALTHCHECK_LOG_FILE=/var/log/healthcheck.log \
    TIMEZONE=UTC

# Configuration files
COPY configs/nginx/default.conf /etc/nginx/sites-enabled/default
COPY configs/php/pool.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Healthcheck
COPY healthcheck/healthcheck.sh /usr/local/bin/healthcheck
COPY healthcheck/nginx.sh /usr/local/bin/nginx-healthcheck
COPY healthcheck/php-fpm.sh /usr/local/bin/php-fpm-healthcheck

HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 CMD healthcheck

COPY configs/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy startup script
COPY scripts/startup.sh /bin/startup
RUN chmod 755 /bin/startup

ENTRYPOINT ["startup"]

CMD ["supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
