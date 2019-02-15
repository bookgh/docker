### 构建 MySQL-5.1.73 rpm包

    # docker 版
    ./rpm-build.sh docker
    
    # 物理机或虚拟机版
    ./rpm-build.sh machine

### 构建完成后的包路径

>/root/rpmbuild/RPMS/mysql-5.1.73-1.el7.centos.x86_64.rpm

    # tree /root/rpmbuild
    /root/rpmbuild/
    ├── BUILD
    ├── BUILDROOT
    ├── RPMS
    │   └── x86_64
    │       ├── mysql-5.1.73-1.el7.centos.x86_64.rpm
    │       └── mysql-debuginfo-5.1.73-1.el7.centos.x86_64.rpm
    ├── SOURCES
    │   ├── my.cnf
    │   ├── mysql-5.1.73.tar.gz
    │   └── mysqld.server
    ├── SPECS
    │   └── mysql.spec
    └── SRPMS

### 手动安装

    请查看 rpm-build.sh 文件
