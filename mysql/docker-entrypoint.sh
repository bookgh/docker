#!/bin/bash
set -xe

. /root/.bash_profile

if [ ! -d "/var/lib/mysql/mysql" ];then
    mkdir -p /var/lib/mysql

    echo 'Initializing database'
    /usr/local/mysql/bin/mysql_install_db --basedir=/usr/local/mysql --datadir=/var/lib/mysql --user=mysql
    echo 'Database initialized'


    
fi

exec "$@"
