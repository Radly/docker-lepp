#!/bin/bash

set -e

case "$1" in

start)
        service ssh start
	service php5-fpm start
	service postgresql start
        nginx -g "daemon off;"
    ;;
provision)
        echo "Hello provisioning"
    ;;
*)
        exec "$@"
   ;;
esac
