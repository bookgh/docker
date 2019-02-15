### 生成镜像

    docker build -t mysql:5.1 .

### 启动容器

    docker run -d --name mysql -p 3306:3360 -v /mysql/data:/var/lib/mysql mysql:5.1

### 清理环境

    docker stop mysql
    docker rm mysql
    docker rmi mysql:5.1

