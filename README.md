Linux + Nginx + Php-fpm + MySql Development Environment for Magento, Symfony, Laravel and others
===============================

## What will be installed

* nginx - 1.8.0
* php - 5.5 with intl, mcrypt, pdo, curl, gd, sqlite, xmlrpc, xsl
* xhprof - (php profiler, for enable in project just add "xhprof" param to query string in url, example: http://myapp.loc?xhprof)
* percona-server - 5.5
* composer - latest

## Ubuntu 14.04

#### Installation:

```bash
$ sudo apt-get install git
$ git clone git@github.com:SergeyCherepanov/lnpm-env-dev.git /tmp/lnpm-env-dev
$ sudo bash /tmp/lnpm-env-dev/install-1404.sh
```

#### Usage:

For example we'll use *website.loc* hostname for project on local machine

1. Add `127.0.0.1 myapp.loc www.myapp.loc` to your /etc/hosts file
2. Put your source code to /var/www/loc/myapp, *web* (or *public*) folder will be resolved automatically by nginx
3. Project will be available by link: http://myapp.loc or http://www.myapp.loc

> note: for third level domain like dev.myapp.loc you should put code to /var/www/loc/dev.myapp folder

> mysql root password is: root

## Vagrant

#### Installation

Install VirtualBox https://www.virtualbox.org/wiki/Downloads

Install Vagrant from http://www.vagrantup.com/downloads

Install Vagrant plugins:

    $ vagrant plugin install vagrant-hostmanager

*Ubuntu/Debian Only:*

    $ sudo apt-get install nfs-kernel-server nfs-common

#### Usage

    $ git clone git@github.com:SergeyCherepanov/lnpm-env-dev.git
    $ cd lnpm-env-dev
    $ vagrant up

> If you want to change project hostname name, you must edit Vagrantfile and replace `NAME="lnpm"` to `NAME="youprojectname"`

> If you want to change mysql credentials, you must edit it in Vagrantfile (by default db name, db user and db password is: lnpm)

> Source code must be placed to **www** folder

> By default project will be available on: http://youprojectname.loc (default is ttp://lnpm.loc)



