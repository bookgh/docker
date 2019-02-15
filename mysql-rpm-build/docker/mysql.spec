Name:		mysql
Version:	5.1.73
Release:	1%{?dist}
Summary:	MySQL-5.1.73

Group:		applications/database
License:	GPL
Distribution:   CentOS
URL:		http://dev.mysql.com/get/Downloads/MySQL-5.1/mysql-5.1.73.tar.gz
Source0:	mysql-5.1.73.tar.gz
Source1:	my.cnf
Source2:	mysqld.server

BuildRequires:	gcc = 4.8.5, gcc-c++ = 4.8.5, ncurses = 5.9, ncurses-devel = 5.9
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Packager:       544025211@qq.com
Autoreq:        no
Prefix:		/usr/local/mysql

%description
The MySQL(TM) software delivers a very fast, multi-threaded, multi-user, 
and robust SQL (Structured Query Language) database server. MySQL Server 
is intended for mission-critical, heavy-load production systems as well 
as for embedding into mass-deployed software.

%define MYSQL_USER mysql
%define MYSQL_GROUP mysql


%prep
%setup -n mysql-%{version}


%build
./configure --prefix=%{prefix} \
  --without-debug \
  --with-charset=utf8 \
  --with-extra-charsets=all \
  --enable-assembler \
  --with-pthread \
  --enable-thread-safe-client \
  --with-mysqld-ldflags=-all-static \
  --with-client-ldflags=-all-static \
  --with-big-tables \
  --with-readline \
  --with-ssl \
  --with-embedded-server \
  --enable-local-infile \
  --with-plugins=innobase
make %{?_smp_mflags}


%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
rm -rf %{buildroot}%{prefix}/mysql-test
%{__install} -p -D %{SOURCE1} %{buildroot}/etc/my.cnf
%{__install} -p -D -m 0775 %{SOURCE2} %{buildroot}/etc/init.d/mysqld


%clean
rm -rf %{buildroot}


%pre
id -g %{MYSQL_GROUP} >/dev/null 2>&1 || groupadd %{MYSQL_GROUP}
id -u %{MYSQL_USER}  >/dev/null 2>&1 || useradd -s /sbin/nologin -M -g %{MYSQL_GROUP} %{MYSQL_USER}


%post
mkdir /etc/my.cnf.d
echo "export PATH=.:\$PATH:%{prefix}/bin;" >> /etc/profile


%preun
/etc/init.d/mysqld stop >/dev/null 2>&1
userdel %{MYSQL_USER} >/dev/null 2>&1
cp /etc/my.cnf %{prefix} >/dev/null 2>&1
mv /etc/my.cnf{,-`date +%m%d%H%M`} >/dev/null 2>&1


%files 
%defattr(-, %{MYSQL_USER}, %{MYSQL_GROUP})
%attr(755, %{MYSQL_USER}, %{MYSQL_GROUP}) %{prefix}/*
/etc/init.d/mysqld
/etc/my.cnf

%changelog
 * Fri Feb  1 2019 WHHC <xiongjunfeng@haocang.com>
 - ver 1.11
