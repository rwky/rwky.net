FROM phusion/passenger-customizable:1.0.10
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN curl -sS -o node.sh https://deb.nodesource.com/setup_12.x && \
bash node.sh && \
apt-get update && \
apt-get -y upgrade && \
apt-get -y install nodejs make && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down
ADD ./conf/nginx /etc/nginx/sites-enabled/default
ADD app/ /home/app/
RUN cd /home/app && make dist
EXPOSE 80
