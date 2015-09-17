#!/usr/bin/env bash
set -e

RAD_PASSWORD="${RAD_PASSWORD:-radphp}"
ROOT_PASSWORD="${ROOT_PASSWORD:-rootphp}"

RADPHP_POSTGRES_PASSWORD="${RADPHP_POSTGRES_PASSWORD:-radphp}"

RADPHP_NGINX_LISTEN="${RADPHP_NGINX_LISTEN:-80}"
RADPHP_NGINX_SERVER_NAME="${RADPHP_NGINX_SERVER_NAME:-localhost 127.0.0.1}"
DEFAULT_NGINX_LISTEN="${DEFAULT_NGINX_LISTEN:-8080}"
DEFAULT_NGINX_SERVER_NAME="${DEFAULT_NGINX_SERVER_NAME:-localhost 127.0.0.1}"

nginxConfig () {
  sed 's/{{RADPHP_NGINX_LISTEN}}/'"${RADPHP_NGINX_LISTEN}"'/' -i /etc/nginx/sites-enabled/radphp
  sed 's/{{RADPHP_NGINX_SERVER_NAME}}/'"${RADPHP_NGINX_SERVER_NAME}"'/' -i /etc/nginx/sites-enabled/radphp

  sed 's/{{DEFAULT_NGINX_LISTEN}}/'"${DEFAULT_NGINX_LISTEN}"'/' -i /etc/nginx/sites-enabled/default
  sed 's/{{DEFAULT_NGINX_SERVER_NAME}}/'"${DEFAULT_NGINX_SERVER_NAME}"'/' -i /etc/nginx/sites-enabled/default
}

appInit () {
  echo 'Init ...'
  echo "radphp:$RAD_PASSWORD" | chpasswd
  echo "root:$ROOT_PASSWORD" | chpasswd

  nginxConfig
}

afterStart () {
  echo "ALTER ROLE postgres WITH PASSWORD '$RADPHP_POSTGRES_PASSWORD';" | sudo -u postgres psql
}

appStart () {
  appInit

  echo 'Start ...'
  service ssh start
  /usr/local/bin/svscanboot &
  service php5-fpm start
  service postgresql start

  afterStart

  nginx -g "daemon off;"
}

appHelp () {
  echo "Available options:"
  echo " start          - Starts the lepp server (default)"
  echo " init           - Initialize the lepp server but don't start it."
  echo " help           - Displays the help"
  echo " [command]      - Execute the specified linux command eg. bash."
}

case "$1" in
  start)
    appStart
    ;;
  init)
    appInit
    ;;
  help)
    appHelp
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "$prog" ] ; then
        shift 1
        ${prog} $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
