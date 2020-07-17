# Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="Zibusiso Edwin Ndlovu ndlovuzibusiso@gmail.com"
LABEL version="1.0"
LABEL description="This is custom Docker Image for \
running nginx and php 7.x"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt install -y nginx php-fpm supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean
    
# Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.4/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable PHP-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
    
# Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

COPY index.php /var/www/html 
    
# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]


#ADD https://gist.githubusercontent.com/zibusiso-ndlovu/b8c473e5976d67d7d04bab913d07c239/raw/980f818cdefb7dcd497a23013de6f216bd9dd577/index.php /var/www/html/index.php
# Copy start.sh script and define default command for the container
COPY start.sh /start.sh
CMD ["./start.sh"]

# Expose Port for the Application 
EXPOSE 80 443