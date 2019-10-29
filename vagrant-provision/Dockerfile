FROM phusion/passenger-customizable:1.0.8
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN curl -sS -o node.sh https://deb.nodesource.com/setup_12.x && \
bash node.sh && \
apt-get update && \
apt-get -y install nodejs && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
rm -rf /home/app && ln -sf /vagrant/app /home/app && \
npm -g install grunt-cli
COPY nginx /etc/nginx/sites-enabled/default
EXPOSE 80
WORKDIR /vagrant/app
