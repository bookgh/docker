#!/bin/bash
set -xe

. /etc/profile

# 判断默认变量是否存在
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# 执行自定义脚本或数据库
process_init_file() {
    local f="$1"; shift

    case "$f" in
        *.sh)     echo "$0: running $f"; . "$f" ;;
        *.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
        *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
        *)        echo "$0: ignoring $f" ;;
    esac
    echo
}


if [ ! -d "/var/lib/mysql/mysql" ];then

    # 初始化数据库
    echo 'Initializing database'
    mysql_install_db --basedir=/usr/local/mysql --datadir=/var/lib/mysql --user=mysql
    echo 'Database initialized'

    /etc/init.d/mysqld start

    # 如果未指定root密码则随机生成密码
    file_env 'MYSQL_ROOT_PASSWORD'
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        export MYSQL_ROOT_PASSWORD="$(cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c32)"
        echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
    fi

    # 拼接授权语句
    file_env 'MYSQL_ROOT_HOST' '%'
    if [ ! -z "$MYSQL_ROOT_HOST" -a "$MYSQL_ROOT_HOST" != 'localhost' ]; then
        read -r -d '' rootCreate <<-EOSQL || true
            CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
            GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION ;
	EOSQL
    fi

    # 删除数据库用户,设置root账号密码,删除测试账号
    mysql=( mysql )
    "${mysql[@]}" <<-EOSQL
        SET @@SESSION.SQL_LOG_BIN=0;
        DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost') ;
        SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
        GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
        ${rootCreate}
        DROP DATABASE IF EXISTS test ;
        FLUSH PRIVILEGES ;
	EOSQL

    # root配置密码后增加参数登录
    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
        mysql+=( -uroot -p"${MYSQL_ROOT_PASSWORD}" )
    fi

    # 检测是否需要创建数据库
    file_env 'MYSQL_DATABASE'
    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
        mysql+=( "$MYSQL_DATABASE" )
    fi

    # 创建指定的账户
    file_env 'MYSQL_USER'
    file_env 'MYSQL_PASSWORD'
    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"
        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
        fi
        echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
    fi

    ls /docker-entrypoint-initdb.d/ > /dev/null
    for f in /docker-entrypoint-initdb.d/*; do
        process_init_file "$f"
    done

    /etc/init.d/mysqld stop

    echo
    echo 'MySQL init process done. Ready for start up.'
    echo
fi

exec "$@"
