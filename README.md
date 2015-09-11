Linux + Nginx + Php-fpm + MySql Dev Environment for Magento, Symfony, Laravel and others
===============================

## What will be installed

1 .nginx - 1.8.0
2. php - 5.5 with intl, mcrypt, pdo, curl, gd, sqlite, xmlrpc, xsl
3. xhprof - (php profiler, for enable in project just add "xhprof" param to query string in url, example: http://myapp.loc?xhprof)
4. percona-server - 5.6
5. composer - latest
6. git



## Installation - Ubuntu 14.04:

```bash
$ wget -nv -O - https://raw.githubusercontent.com/SergeyCherepanov/lnpm-env-dev/master/install-1404.sh | sudo bash
```

## Usage:

For example we'll use *website.loc* hostname for project on local machine

1. Add `127.0.0.1 myapp.loc www.myapp.loc` to your /etc/hosts file
2. Put your source code to /var/www/loc/myapp, *web* (or *public*) folder will be resolved automatically by nginx
3. Project will be available by link: http://myapp.loc or http://www.myapp.loc

> note: for third level domain like dev.myapp.loc you should put code to /var/www/loc/dev.myapp folder
