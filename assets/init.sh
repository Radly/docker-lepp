#!/usr/bin/env bash
set -e

RAD_PASSWORD="${RAD_PASSWORD:-radphp}"
ROOT_PASSWORD="${ROOT_PASSWORD:-rootphp}"

appInit () {
  echo 'Init ...'
  echo "radphp:$RAD_PASSWORD" | chpasswd
  echo "root:$ROOT_PASSWORD" | chpasswd
}

appStart () {
  appInit

  echo 'Start ...'
  service ssh start
  /usr/local/bin/svscanboot
  service php5-fpm start
  service postgresql start
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
