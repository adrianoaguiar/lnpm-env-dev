Vagrant Development Environment for Symfony, Laravel, Magento
==============================================================

## Supported providers:

* VirtualBox
* Docker

## What will be installed

* nginx v.1.8
* php v.5.5 with intl, mcrypt, pdo, curl, gd, sqlite, xmlrpc, xsl, ioncube, xhprof
* composer
* percona-server 
* node.js, ruby, scss, less, compass

## Vagrant Installation

Install VirtualBox https://www.virtualbox.org/wiki/Downloads

Install Vagrant from http://www.vagrantup.com/downloads

Install Vagrant plugins:

    $ vagrant plugin install vagrant-hostmanager

Optional (windows host only): install nfs plugin

    $ vagrant plugin install vagrant-winnfsd

**Linux Only (Ubuntu):**

**Provider: VirtualBox**

Install NFS Server and tools

    $ sudo apt-get -q -y install nfs-kernel-server nfs-common
    
Enable ip forwarding
    
    $ sudo sed -i -e "s/#\s*net.ipv4.ip_forward\s*=.*/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
    $ sudo sysctl -p /etc/sysctl.conf

**Provider: Docker**

Install Docker

    $ curl -sL https://get.docker.io/ | sudo sh

or 

    $ wget -qO- https://get.docker.io/ | sudo sh

if you get: `/usr/sbin/mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: Permission denied` run on the host:

    $ sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
    $ sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld

### Vagrant Usage

    $ git clone https://github.com/SergeyCherepanov/lnpm-env-dev.git
    $ cd lnpm-env-dev
    
Run with virtualbox provider

    $ vagrant up
    
Run with docker provider

    $ vagrant up --provider=docker

> If you want to change project hostname name, you must edit Vagrantfile and replace `NAME="lnpm"` to `NAME="youprojectname"`

> If you want to change mysql credentials, you must edit it in Vagrantfile (by default db name, db user and db password is: lnpm)

> Source code must be placed to **www** folder

> By default project will be available on: http://project.loc (default it's: http://lnpm.loc)

    
    
## Ubuntu 14.04 Installation

```bash
$ sudo apt-get -q -y install git
$ git clone https://github.com/SergeyCherepanov/lnpm-env-dev.git /tmp/lnpm-env-dev
$ sudo bash /tmp/lnpm-env-dev/install-1404.sh
```

#### Usage:

For example we'll use *website.loc* hostname for project on local machine

1. Add `127.0.0.1 myapp.loc www.myapp.loc` to your /etc/hosts file
2. Put your source code to /var/www/loc/myapp, *web* (or *public*) folder will be resolved automatically by nginx
3. Project will be available by link: http://myapp.loc or http://www.myapp.loc

> note: for third level domain like dev.myapp.loc you should put code to /var/www/loc/dev.myapp folder

> mysql root password is: root


