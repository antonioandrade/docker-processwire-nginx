FROM phusion/baseimage
MAINTAINER Antonio Andrade <antonio@antonioandra.de>

# Keep upstart
RUN dpkg-divert --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl

# Set no tty
ENV DEBIAN_FRONTEND noninteractive

# Update System
RUN apt-get update && \
    apt-get -y upgrade

# Basic Requirements
RUN apt-get install -y pwgen --force-yes python-setuptools curl git unzip \
    mysql-server mysql-client \
    nginx \
    php5-fpm php5-mysql php-apc php5-cli php5-curl php5-gd php5-mcrypt php5-intl  \
    php5-imap php5-tidy php5-imagick php5-memcache php5-xmlrpc php5-xsl

# MySQL Config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \

# Nginx Config
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./config/nginx-site.conf /etc/nginx/sites-available/default

# PHP Config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1000M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 1000M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf && \
    find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Supervisor Config
RUN easy_install supervisor
ADD ./config/supervisord.conf /etc/supervisord.conf

# Volume
VOLUME ["/usr/share/nginx"]

# Expose
EXPOSE 80
EXPOSE 3306

# Startup Script
ADD ./scripts/start.sh /scripts/start.sh
RUN chmod 755 /scripts/start.sh
CMD ["/bin/bash", "/scripts/start.sh"]

# Clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*