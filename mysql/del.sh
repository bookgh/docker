#!/bin/bash

docker stop  mysql
docker rm  mysql
docker rmi  mysql:5.1

cat <<!
docker build -t mysql:5.1 .
docker run -d --name mysql -p 3306:3360 -v /root/hubdocker/mysql/data:/var/lib/mysql mysql:5.1
!
