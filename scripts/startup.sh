#!/bin/bash

# Setup timezone
ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo $TIMEZONE > /etc/timezone

DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata

# Start supervisor
exec "$@"