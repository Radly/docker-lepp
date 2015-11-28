#!/usr/bin/env bash
set -e

RAD_USER=radphp
RAD_GROUP=radphp

# Add & config radphp user
echo "$RAD_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd --create-home --user-group -s /usr/bin/zsh ${RAD_USER}
sudo -u ${RAD_USER} -H sh -c "export SHELL=/usr/bin/zsh; curl -L http://install.ohmyz.sh | bash"
sudo -u ${RAD_USER} -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"maran\"/g' /home/$RAD_USER/.zshrc"

# Install Djbdns & Daemontools
mkdir -p /package
chmod 1755 /package
cd /package
curl -SLO http://cr.yp.to/daemontools/daemontools-0.76.tar.gz
tar -zxvpf daemontools-0.76.tar.gz
cd admin/daemontools-0.76
sed -i "s/extern int errno;/#include <errno.h>/g" src/error.h
package/install
cd /package
curl -SLO http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
tar -zxvpf djbdns-1.05.tar.gz
cd /package/djbdns-1.05
sed -i "s/extern int errno;/#include <errno.h>/g" error.h
make
make setup check
useradd --system --no-create-home --shell /bin/false tinydns
useradd --system --no-create-home --shell /bin/false dnslog
tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0
mkdir /etc/service
ln -s /etc/tinydns /etc/service
ln -s /etc/tinydns /service

# Install Adminer
mkdir -p /srv/tools/adminer
cd /srv/tools/adminer
curl -SLO http://www.adminer.org/latest.php
curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer.css
curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer-bg.png
mv latest.php index.php

# Install phpPgAdmin
mkdir -p /srv/tools/phppgadmin
cd /srv/tools/phppgadmin
git clone git://github.com/phppgadmin/phppgadmin.git .
mv conf/config.inc.php-dist conf/config.inc.php
sed -i "s/$conf\['extra_login_security'\] = true/$conf\['extra_login_security'\] = false/g" conf/config.inc.php

# PHP Config
cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/\[www\]/\[radphp\]/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/user = www-data/user = $RAD_USER/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/group = www-data/group = $RAD_GROUP/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php5-fpm-radphp.sock/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen.owner = www-data/listen.owner = $RAD_USER/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen.group = www-data/listen.group = $RAD_GROUP/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/;date.timezone =.*/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone =.*/date.timezone = UTC/g" /etc/php5/cli/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 12M/g" /etc/php5/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/g" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/cli/php.ini
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/fpm/php.ini
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/cli/php.ini

# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Config Nginx
cp /opt/radphp/configs/nginx/default /etc/nginx/sites-available/
cp /opt/radphp/configs/nginx/radphp /etc/nginx/sites-enabled/
