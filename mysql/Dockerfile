FROM centos:7.5.1804

# 安装mysql
RUN yum install -y http://file.freefrp.cn/shared/mysql-5.1.73-1.el7.centos.x86_64.rpm \
 && yum clean all

ENV PATH=/usr/local/mysql/bin:$PATH

RUN mkdir /docker-entrypoint-initdb.d

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld_safe"]
