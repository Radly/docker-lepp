#!/bin/bash

set -e

case "$1" in

start)
        /etc/init.d/php5-fpm start
	/etc/init.d/postgresql start
        nginx -g "daemon off;"
    ;;
provision)
        echo "Hello provisioning"
    ;;
*)
        exec "$@"
   ;;
esac
