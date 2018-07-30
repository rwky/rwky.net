FROM rwky/phusion-passenger:latest 
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN curl -sS -o node.sh https://deb.nodesource.com/setup_10.x && \
bash node.sh && \
apt-get update && \
apt-get -y install nodejs exim4-daemon-light && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
rm -rf /etc/service/rsyslog/down
ADD ./conf/nginx /etc/nginx/conf.d/rwky.net.conf
RUN npm -g install grunt-cli
ADD app/package-lock.json /home/app/
ADD app/package.json /home/app/
RUN cd /home/app && npm install
ADD app/ /home/app
RUN cd /home/app && grunt dist
EXPOSE 80 443

