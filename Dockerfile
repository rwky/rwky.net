FROM phusion/passenger-customizable:1.0.6
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN curl -sS -o node.sh https://deb.nodesource.com/setup_10.x && \
bash node.sh && \
apt-get update && \
apt-get -y upgrade && \
apt-get -y install nodejs && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
curl -sS -o /srv/dhparam.pem https://ssl-config.mozilla.org/ffdhe2048.txt
ADD ./conf/nginx /etc/nginx/sites-enabled/default
RUN npm -g install grunt-cli
ADD app/package-lock.json /home/app/
ADD app/package.json /home/app/
RUN cd /home/app && npm install
ADD app/ /home/app
RUN cd /home/app && grunt dist
EXPOSE 80 443

