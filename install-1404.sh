#!/usr/bin/env bash
DIR=$(dirname $(readlink -f $0))
TMPDIR=/tmp/lnpm-env-dev

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

DEBCONF_PREFIX="percona-server-server-5.5 percona-server-server"
PERCONA_PW="root"
echo "${DEBCONF_PREFIX}/root_password password $PERCONA_PW" | sudo debconf-set-selections
echo "${DEBCONF_PREFIX}/root_password_again password $PERCONA_PW" | sudo debconf-set-selections

# Clean tmp dir
if [ -d ${TMPDIR} ]; then
    rm -rf ${TMPDIR}
fi

# Nginx repo
add-apt-repository -y ppa:nginx/stable

# Graphviz repo
apt-add-repository -y ppa:dperry/ppa-graphviz-test

# Percona repo
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo "deb http://repo.percona.com/apt "$(lsb_release -sc)" main" | tee /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt "$(lsb_release -sc)" main" | tee -a /etc/apt/sources.list.d/percona.list

# Update
# --------------------
apt-get update
apt-get -y upgrade

# Install base packages
apt-get install -q -y git-core unzip curl zlib1g-dev build-essential libssl-dev \
libreadline-dev libyaml-dev python-software-properties \
libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev sqlite3 \
libgdbm-dev libncurses5-dev automake libtool bison libffi-dev

# Install Percona-Server
apt-get -q -y install percona-server-server-5.5 percona-server-client-5.5

# Install nginx + php-fpm
apt-get install -q -y nginx php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd \
php5-mcrypt php5-sqlite php5-xmlrpc php5-xsl php5-common php5-intl

# Install Compass
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
rvm install 2.1.2
rvm use 2.1.2 --default
ruby -v

gem install compass

# Install xhprof
pecl install -f xhprof

# Enabling mcrypt
php5enmod mcrypt

# Install graphviz
apt-get autoremove -q -y graphviz libpathplan4
apt-get install -q -y graphviz

# Install composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Resolve environment configs
if [ 'install-1404.sh' = "$(basename `readlink -f $0`)" ] && [ -d ${DIR}/conf ]; then
    cp -r ${DIR}/conf ${TMPDIR}/conf
    cd ${TMPDIR}
else
    wget -O /tmp/conf.zip https://github.com/SergeyCherepanov/lnpm-env-dev/archive/master.zip
    unzip /tmp/conf.zip -d ${TMPDIR}
    rm /tmp/conf.zip
    cd ${TMPDIR}/$(ls -1 ${TMPDIR}/ | head -1)
fi

# Prepare environment configs
# --------------------
mv ./conf/nginx/sites-available/dev /etc/nginx/sites-available/dev
mv ./conf/mysql/my.cnf              /etc/mysql/my.cnf
mv ./conf/php/php.ini               /etc/php5/fpm/php.ini
mv ./conf/php/xhprof.ini            /etc/php5/mods-available/xhprof.ini

ln -s /etc/nginx/sites-available/dev /etc/nginx/sites-enabled/dev
ln -s /etc/php5/mods-available/xhprof.ini /etc/php5/fpm/conf.d/20-xhprof.ini

unlink /etc/nginx/sites-enabled/default

rm /var/lib/mysql/ibdata1
rm /var/lib/mysql/ib_logfile0
rm /var/lib/mysql/ib_logfile1

mkdir -p /var/www
chown www-data:www-data /var/www
chown www-data:www-data -R /usr/share/php/xhprof_html

cat <<EOF  > /var/www/.xhprof-header.php
<?php

if (extension_loaded('xhprof') && isset(\$_GET['xhprof'])) {
    require '/usr/share/php/xhprof_lib/utils/xhprof_lib.php';
    require '/usr/share/php/xhprof_lib/utils/xhprof_runs.php';
    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
}

EOF

cat <<EOF  > /var/www/.xhprof-footer.php
<?php
if (isset(\$_GET['xhprof']) && extension_loaded('xhprof')) {
    \$profiler_namespace = 'myapp';  // namespace for your application
    \$xhprof_data = xhprof_disable();
    \$xhprof_runs = new XHProfRuns_Default();
    \$run_id = \$xhprof_runs->save_run(\$xhprof_data, \$profiler_namespace);

    // url to the XHProf UI libraries (change the host name and path)
    \$profiler_url = sprintf('/xhprof/index.php?run=%s&amp;source=%s', \$run_id, \$profiler_namespace);
    echo '<a href="'. \$profiler_url .'" target="_blank">Profiler output</a>';
}

EOF

# Restart service
service nginx restart
service php5-fpm restart
service mysql restart

# Cleanup
rm -rf $TMPDIR
