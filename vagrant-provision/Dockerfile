FROM phusion/passenger-customizable:1.0.12
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN curl -sS -o node.sh https://deb.nodesource.com/setup_14.x && \
bash node.sh && \
apt-get update && \
apt-get -y install nodejs make && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
rm -rf /home/app && ln -sf /vagrant/app /home/app
COPY nginx /etc/nginx/sites-enabled/default
EXPOSE 80
WORKDIR /vagrant/app
