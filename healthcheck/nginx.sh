#!/bin/bash

if ! service nginx status; then
  exit 1
fi

NGINX_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1/nginx_status)

if [[ $NGINX_STATUS_CODE != 200 ]]; then
  exit 1
fi

exit 0