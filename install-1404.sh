#!/usr/bin/env bash
# Ignore the questions
export DEBIAN_FRONTEND=noninteractive
TMPDIR=/tmp/magentoenvironmentconfiguration
# Update
# --------------------
apt-get update
apt-get -y upgrade
# Mysql
# --------------------
# Install MySQL quietly
apt-get -q -y install mysql-server
# Install nginx + varnish + php-fpm
apt-get install -y git mysql-client vim nginx php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd php5-mcrypt php5-sqlite php5-xmlrpc php5-xsl php5-common php5-intl
php5enmod mcrypt
git clone  https://github.com/SergeyCherepanov/lnpm-env-dev.git $TMPDIR
cd $TMPDIR

# Prepare environment config
# --------------------
unlink /etc/nginx/sites-available/default
cp ./conf/nginx/sites-available/dev /etc/nginx/sites-available/dev
cp ./conf/mysql/my.cnf /etc/mysql/my.cnf
cp ./conf/php/php.ini /etc/php5/fpm/php.ini
mkdir /var/www
chown www-data:www-data /var/www
rm /var/lib/mysql/ibdata1
rm /var/lib/mysql/ib_logfile0
rm /var/lib/mysql/ib_logfile1
service nginx restart
service php5-fpm restart
service mysql restart

rm -rf $TMPDIR
