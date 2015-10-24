############################################################
# Dockerfile to build Tech Ministry's website
# Based on Debian
############################################################

# Set the base image to Debian
FROM debian:jessie

# File Author / Maintainer
MAINTAINER aldor

################## BEGIN INSTALLATION ######################
# Update the repository sources list
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.4-1~jessie

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} git


# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /etc/nginx/sites-available/
RUN echo "server { \n        listen   80;\n\n        root usr/share/nginx/html/; \n\
        index index.php index.html index.htm;\n\n        server_name techministry.gr;\n\n\
        error_page 404 /404.html;\n\n        error_page 500 502 503 504 /50x.html; \n\n\
       location = /50x.html {\n              root /usr/share/nginx/html/;\n        }\n}" \
        >/etc/nginx/sites-available/default
WORKDIR usr/share/nginx/html/
RUN rm *
RUN git clone https://github.com/techministry/website /usr/share/nginx/html/

################## INSTALLATION END ######################

EXPOSE 80 443
CMD service nginx stop && git pull origin master && service nginx start && /bin/bash