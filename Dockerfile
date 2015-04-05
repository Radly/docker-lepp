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
                        nginx openssh-server postgresql-client postgresql-server redis-tools supervisor \
                        php5-cli php5-curl php-pear php5-dev php5-fpm php5-gd php5-intl php5-pgsql php5-redis php5-xdebug php5-xsl \
 && rm -rf /var/lib/apt/lists/*

# Add & config radphp user
RUN echo "radphp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && useradd --create-home --user-group -s /usr/bin/zsh radphp \
 && echo "radphp:radphp"|chpasswd \
 && sudo -u radphp -H sh -c "export SHELL=/usr/bin/zsh; curl -L http://install.ohmyz.sh | bash" \
 && sudo -u radphp -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"maran\"/g' /home/radphp/.zshrc"
