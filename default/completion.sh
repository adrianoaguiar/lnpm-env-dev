#!/bin/bash

HOSTNAME=$1;
DATABASE_NAME=$2;
DATABASE_USER=$3
DATABASE_PASSWORD=$4

cat <<EOF  > /etc/update-motd.d/99-lnpm-info
#/bin/bash
function info {
    printf "\033[0;36m\${1}\033[0m \n"
}
function note {
    printf "\033[0;33m\${1}\033[0m \n"
}
echo "------------------------------------------------------------"
echo
info "Default URI: http://$HOSTNAME"
echo
note "Database Name: ${DATABASE_NAME}"
note "Database User: ${DATABASE_USER}"
note "Database Password: ${DATABASE_PASSWORD}"
echo
echo "------------------------------------------------------------"
echo
EOF

chmod +x /etc/update-motd.d/99-lnpm-info
/etc/update-motd.d/99-lnpm-info
