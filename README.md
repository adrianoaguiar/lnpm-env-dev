Linux + Nginx + Php-fpm + MySql environment for Magento, Symfony, Laravel and others
===============================

## Ubuntu Installation 14.04:

```bash
$ sudo su
$ bash <(wget -nv -O - https://raw.githubusercontent.com/SergeyCherepanov/lnpm-env-dev/master/install-1404.sh)
```

## Usage:

For example we'll use *website.loc* hostname for project on local machine

1. Add `127.0.0.1 myapp.loc www.myapp.loc` to your /etc/hosts file
2. Put your source code to /var/www/loc/myapp, *web* (or *public*) folder will be resolved automatically by nginx
3. Project will be available by link: http://myapp.loc or http://www.myapp.loc

> note: for third level domain like dev.myapp.loc you should put code to /var/www/loc/dev.myapp folder
