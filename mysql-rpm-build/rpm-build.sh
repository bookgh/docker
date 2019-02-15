#!/bin/bash

# 安装编译环境及依赖
yum install -y wget gcc gcc-c++ ncurses ncurses-devel

# 安装RPM包生成工具
yum install -y rpmdevtools

# 初始化目录结构,复制资源文件到 SOURCES 目录
[ -d /root/rpmbuild ] && rm -rf /root/rpmbuild
rpmdev-setuptree
cp $1/my.cnf /root/rpmbuild/SOURCES
cp $1/mysqld.server /root/rpmbuild/SOURCES
cp $1/mysql-5.1.73.tar.gz /root/rpmbuild/SOURCES
cp $1/mysql.spec /root/rpmbuild/SPECS

# 编译并生成RPM包
rpmbuild -bb /root/rpmbuild/SPECS/mysql.spec

ls /root/rpmbuild/RPMS/x86_64
