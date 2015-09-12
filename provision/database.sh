#!/bin/bash

APP_DB_NAME="$1"
APP_DB_USER="$2"
APP_DB_PASSWORD="$3"

APP_DB_HOST="localhost"
DB_ROOT_PASSWORD="root"

## Add database
if ! (echo 'CREATE DATABASE `'${APP_DB_NAME}'` CHARACTER SET utf8 COLLATE utf8_general_ci;' | mysql -h${APP_DB_HOST} -uroot --password=${DB_ROOT_PASSWORD})
then
  echo "Can't create database"
  exit 1
fi

## Add user
if ! (echo "CREATE USER '${APP_DB_USER}'@'localhost' IDENTIFIED BY '${APP_DB_PASSWORD}';" | mysql -h${APP_DB_HOST} -uroot --password=${DB_ROOT_PASSWORD})
then
  echo "Can't create user"
  exit 1
fi

## Update privileges
if ! (echo "GRANT ALL PRIVILEGES ON ${APP_DB_NAME}.* TO '${APP_DB_USER}'@'localhost' WITH GRANT OPTION;"  | mysql -h${APP_DB_HOST} -uroot --password=${DB_ROOT_PASSWORD})
then
  echo "Can't grant privileges"
  exit 1
fi

## Flush privileges
if ! (echo 'FLUSH PRIVILEGES;' | mysql -h${APP_DB_HOST} -uroot --password=${DB_ROOT_PASSWORD})
then
  echo "Can't update privileges"
  exit 1
fi

