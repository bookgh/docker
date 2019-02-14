FROM centos:7.5.1804

# 安装mysql
RUN yum install -y http://file.freefrp.cn/shared/mysql-5.1.73-1.el7.centos.x86_64.rpm \
 && yum clean all

RUN mkdir /docker-entrypoint-initdb.d

# 创建配置文件
RUN mkdir -p /etc/mysql/conf.d \
 && { \
        echo '[mysqld]'; \
        echo 'skip-host-cache'; \
        echo 'skip-name-resolve'; \
        echo 'datadir = /var/lib/mysql'; \
        echo '!includedir /etc/mysql/conf.d/'; \
    } > /etc/my.cnf

# 创建数据库,pid文件目录
RUN mkdir -p /var/lib/mysql /var/run/mysqld \
 && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
 && chmod 777 /var/run/mysqld

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld_safe"]
