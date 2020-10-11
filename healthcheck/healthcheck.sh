#!/bin/bash

DATE=$(date +%d/%m/%Y)
TIME=$(date +%H:%M:%S)

DATETIME="$DATE $TIME"

# Check if log file exists, if not, create it
if ! test -f "$HEALTHCHECK_LOG_FILE"; then

    touch $HEALTHCHECK_LOG_FILE

    if ! test -f "$HEALTHCHECK_LOG_FILE"; then
      echo "ERROR! Could not create healthcheck log file at $HEALTHCHECK_LOG_FILE. Please, check permissions for this location or try to create the log file manually." >> /dev/stderr
      exit 1
    fi

fi

# Run healthchecks for container services
if ! nginx-healthcheck; then
  echo "ERROR! [$HOSTNAME] [$DATETIME] Healthcheck failed for service Nginx" >> $HEALTHCHECK_LOG_FILE
  exit 1
fi

if ! FCGI_CONNECT=$PHP_FPM_POOL_LISTEN FCGI_STATUS_PATH=$PHP_FPM_POOL_STATUS php-fpm-healthcheck; then
  echo "ERROR! [$HOSTNAME] [$DATETIME] Healthcheck failed for service PHP-FPM" >> $HEALTHCHECK_LOG_FILE
  exit 1
fi

exit 0