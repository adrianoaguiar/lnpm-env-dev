#!/usr/bin/env bash
DIR=$(dirname $(readlink -f $0))
TMPDIR=/tmp/lnpm-env-dev

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

while [[ $# > 1 ]]
do
key="$1"
case ${key} in
    --www-root)
    WWW_ROOT="$2"
    shift
    ;;
    --www-user)
    WWW_USER="$2"
    shift
    ;;
    --www-group)
    WWW_GROUP="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

[[ -z ${WWW_ROOT}  ]] && WWW_ROOT="/var/www"
[[ -z ${WWW_USER}  ]] && WWW_USER="www-data"
[[ -z ${WWW_GROUP} ]] && WWW_GROUP="www-data"

DEBCONF_PREFIX="percona-server-server-5.5 percona-server-server"
PERCONA_PW="root"
echo "${DEBCONF_PREFIX}/root_password password $PERCONA_PW" | sudo debconf-set-selections
echo "${DEBCONF_PREFIX}/root_password_again password $PERCONA_PW" | sudo debconf-set-selections

# Clean tmp dir
if [ -d ${TMPDIR} ]; then
    rm -rf ${TMPDIR}
fi

mkdir -p ${TMPDIR}

# Nginx repo
add-apt-repository -y ppa:nginx/stable

# Graphviz repo
apt-add-repository -y ppa:dperry/ppa-graphviz-test

# Percona repo
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo "deb http://repo.percona.com/apt "$(lsb_release -sc)" main" | tee /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt "$(lsb_release -sc)" main" | tee -a /etc/apt/sources.list.d/percona.list

# Update
apt-get update
apt-get -y upgrade

# Install Percona-Server
apt-get -q -y install percona-server-server-5.5 percona-server-client-5.5

# Install tools
apt-get install -q -y unzip git-core

# Install nginx
apt-get install -q -y nginx

# Install php
apt-get install -q -y php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd \
php5-mcrypt php5-sqlite php5-xmlrpc php5-xsl php5-common php5-intl

# Install xhprof
pecl install -f xhprof

# Install IonCube
wget -O ${TMPDIR}/ioncube.tgz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_"$([[ "x86_64" = `arch` ]] && echo "x86-64" || echo "x86")".tar.gz"
tar xvzf ${TMPDIR}/ioncube.tgz -C ${TMPDIR}
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_EXTDIR=$(php -i | grep "^extension_dir" | awk '{print $3}')
[[ ! -d ${PHP_EXTDIR} ]] && echo "Extension dir '${EXTDIR}' not found!" && exit 1
cp "${TMPDIR}/ioncube/ioncube_loader_lin_${PHP_VERSION}.so" ${PHP_EXTDIR}
echo "zend_extension = ${PHP_EXTDIR}/ioncube_loader_lin_${PHP_VERSION}.so" > /etc/php5/mods-available/ioncube.ini
ln -s /etc/php5/mods-available/ioncube.ini /etc/php5/cli/conf.d/0-ioncube.ini
ln -s /etc/php5/mods-available/ioncube.ini /etc/php5/fpm/conf.d/0-ioncube.ini

# Enabling mcrypt
php5enmod mcrypt

# Install graphviz
apt-get autoremove -q -y graphviz libpathplan4
apt-get install -q -y graphviz

# Install Ruby + Ruby Compass
apt-get install -q -y ruby ruby-compass

# Install composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Resolve environment configs
if [ -d ${DIR}/conf ]; then
    cp -r ${DIR}/conf ${TMPDIR}/conf
    cd ${TMPDIR}
else
    wget -O /tmp/conf.zip https://github.com/SergeyCherepanov/lnpm-env-dev/archive/master.zip
    unzip /tmp/conf.zip -d ${TMPDIR}
    rm /tmp/conf.zip
    cd ${TMPDIR}/$(ls -1 ${TMPDIR}/ | grep lnpm-env-dev | head -1)
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


sed -i -e "s/\s*set\s\s*\$wwwRoot\s\s*\/var\/www\;/    set \$wwwRoot "$(echo ${WWW_ROOT} | sed -e 's/[\.\:\/&]/\\&/g')";/g" /etc/nginx/sites-available/dev
sed -i -e "s/\s*user\s\s*www-data\;/user ${WWW_USER};/g"   /etc/nginx/nginx.conf
sed -i -e "s/\s*user\s*=\s*www-data/user=${WWW_USER}/g"    /etc/php5/fpm/pool.d/www.conf
sed -i -e "s/\s*group\s*=\s*www-data/group=${WWW_GROUP}/g" /etc/php5/fpm/pool.d/www.conf

rm /var/lib/mysql/ibdata1
rm /var/lib/mysql/ib_logfile0
rm /var/lib/mysql/ib_logfile1

if [ ! -d ${WWW_ROOT} ]; then
    mkdir -p ${WWW_ROOT}
    chown ${WWW_USER}:${WWW_GROUP} ${WWW_ROOT}
fi

chown ${WWW_USER}:${WWW_GROUP} -R /usr/share/php/xhprof_html

cat <<EOF  > ${WWW_ROOT}/.xhprof-header.php
<?php

if (extension_loaded('xhprof') && isset(\$_GET['xhprof'])) {
    require '/usr/share/php/xhprof_lib/utils/xhprof_lib.php';
    require '/usr/share/php/xhprof_lib/utils/xhprof_runs.php';
    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
}

EOF

cat <<EOF  > ${WWW_ROOT}/.xhprof-footer.php
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
