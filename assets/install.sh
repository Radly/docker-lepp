#!/usr/bin/env bash
set -e

USER=radphp
GROUP=radphp
PASS=radphp

# Add & config radphp user
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd --create-home --user-group -s /usr/bin/zsh ${USER}
echo "$USER:$PASS"|chpasswd
sudo -u ${USER} -H sh -c "export SHELL=/usr/bin/zsh; curl -L http://install.ohmyz.sh | bash"
sudo -u ${USER} -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"maran\"/g' /home/$USER/.zshrc"


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
sed -i "s/user = www-data/user = $USER/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/group = www-data/group = $GROUP/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php5-fpm-radphp.sock/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen.owner = www-data/listen.owner = $USER/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/listen.group = www-data/listen.group = $GROUP/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/radphp.conf
sed -i "s/;date.timezone =/date.timezone = Asia\/Tehran/g" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Tehran/g" /etc/php5/cli/php.ini
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
