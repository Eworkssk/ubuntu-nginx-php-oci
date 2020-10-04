FROM ubuntu:20.04

# Versions
ENV NGINX_VERSION=1.18.* \
    SUPERVISOR_VERSION=4.1.* \
    PHP_VERSION=7.4 \
    PHP_REDIS_VERSION=5.3.* \
    IMAGICK_VERSION=8:6.9.10.* \
    PHP_IMAGICK_VERSION=3.4.* \
    ORACLE_INSTANTCLIENT_VERSION="19_8" \
    PHP_OCI_VERSION=2.2.0 \
    GHOSTSCRIPT_VERSION=9.50* \
    POPPLER_UTILS_VERSION=0.86.* \
    LOGROTATE_VERSION=3.14.*

ARG DEBIAN_FRONTEND=noninteractive

# Install apt-utils
RUN apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y apt-utils && \
    rm -rf /var/lib/apt/lists/* && apt-get autoremove -y && apt-get clean -y

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
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean -y

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
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean -y

# Copy Oracle Instantclient files
COPY ./instantclient/instantclient.zip /instantclient.zip
COPY ./instantclient/instantclient_sdk.zip /instantclient_sdk.zip

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

EXPOSE 80
EXPOSE 443

RUN ln -s /usr/bin/pdftotext /usr/local/bin/pdftotext && chmod 755 /usr/local/bin/pdftotext

COPY ./eworks-logo.png /var/www/html/eworks-logo.png
COPY ./index.html /var/www/html/index.html

# ENV variables
ENV ENVIRONMENT=development \
    IMAGE_TYPE=generic

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]