FROM debian:wheezy
MAINTAINER Mohammad Abdoli Rad <m.abdolirad@gmail.com>

# Install Requirment
# - Dotdeb key 89DF5277
# - Postgresql key ACCC4CF8
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 89DF5277 \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCC4CF8 \
 && echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list.d/dotdeb.list \
 && echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list.d/dotdeb.list \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" >> /etc/apt/sources.list.d/postgresql.list \
 && apt-get update \
 && DEBCONF_FRONTEND=noninteractive apt-get install -y curl sudo zsh git zip dnsutils mlocate logrotate locales nano \
                        nginx openssh-server postgresql-client postgresql \
                        php5-cli php5-curl php-pear php5-dev php5-fpm php5-gd php5-intl php5-pgsql php5-redis php5-xdebug php5-xsl \
 && rm -rf /var/lib/apt/lists/*

# Add & config radphp user
RUN echo "radphp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && useradd --create-home --user-group -s /usr/bin/zsh radphp \
 && echo "radphp:radphp"|chpasswd \
 && sudo -u radphp -H sh -c "export SHELL=/usr/bin/zsh; curl -L http://install.ohmyz.sh | bash" \
 && sudo -u radphp -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"maran\"/g' /home/radphp/.zshrc"

# Install Adminer
RUN mkdir -p /srv/tools/adminer \
 && cd /srv/tools/adminer \
 && curl -SLO http://www.adminer.org/latest.php \
 && curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer.css \
 && curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer-bg.png \
 && mv latest.php index.php

# Install phpPgAdmin
RUN mkdir -p /srv/tools/phppgadmin \
 && cd /srv/tools/phppgadmin \
 && git clone git://github.com/phppgadmin/phppgadmin.git . \
 && mv conf/config.inc.php-dist conf/config.inc.php \
 && sed -i "s/$conf\['extra_login_security'\] = true/$conf\['extra_login_security'\] = false/g" conf/config.inc.php

# PHP Config
RUN cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/\[www\]/\[radphp\]/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/user = www-data/user = radphp/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/group = www-data/group = radphp/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php5-fpm-radphp.sock/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/listen.owner = www-data/listen.owner = radphp/g" /etc/php5/fpm/pool.d/radphp.conf \ 
 && sed -i "s/listen.group = www-data/listen.group = radphp/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/radphp.conf \
 && sed -i "s/;date.timezone =/date.timezone = Asia\/Tehran/g" /etc/php5/fpm/php.ini \
 && sed -i "s/;date.timezone =/date.timezone = Asia\/Tehran/g" /etc/php5/cli/php.ini \
 && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 12M/g" /etc/php5/fpm/php.ini \
 && sed -i "s/post_max_size = .*/post_max_size = 128M/g" /etc/php5/fpm/php.ini

# Config Nginx
COPY ./assets/configs/nginx/default /etc/nginx/sites-available/

# Add init script
COPY ./assets/init.sh /opt/
RUN chmod a+x /opt/init.sh

WORKDIR /srv/www
ENTRYPOINT ["/opt/init.sh"]
CMD ["start"]

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8   
ENV LC_ALL en_US.UTF-8

EXPOSE 80 8080 443
