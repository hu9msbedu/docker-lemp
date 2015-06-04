# nginx + PHP5-FPM + MariaDB + supervisord on Docker
#
# VERSION               0.0.1
FROM        ubuntu:12.04
MAINTAINER  Steeve Morin "steeve.morin@gmail.com"

# Update packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update

# install curl, wget
RUN apt-get install -y curl wget

# Configure repos
RUN apt-get install -y python-software-properties
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://mirrors.linsrv.net/mariadb/repo/5.5/ubuntu precise main'
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php5
RUN apt-get update

# Install MariaDB
RUN apt-get -y install mariadb-server
RUN sed -i 's/^innodb_flush_method/#innodb_flush_method/' /etc/mysql/my.cnf

# Install nginx
RUN apt-get -y install nginx

# Install PHP5 and modules
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-imap php5-mcrypt php5-curl php5-gd php5-json

# Configure nginx for PHP websites
ADD nginx_default.conf /etc/nginx/sites-available/default
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www


# 安装ssh服务
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
# 用户名，密码
RUN echo 'root:12345' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 取消pam的限制，否则用户登录后就被踢出
RUN sed -ri 's/session required pam_loginuid.so/#session required pam_loginuid.so/g' /etc/pam.d/sshd

# Supervisord
RUN apt-get -y install python-setuptools
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80 22

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
CMD ["/usr/sbin/sshd", "-D"]
