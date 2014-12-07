FROM rwky/phusion-passenger:latest 
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN apt-get update && \
apt-get -y install nodejs exim4-daemon-light && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
rm -rf /etc/service/exim/down && \
rm -rf /etc/service/rsyslog/down && \
touch /etc/service/cron/down && \
ln -sf /home/app/config/dh.pem /etc/ssl/dh.pem
ADD ./conf/exim /etc/exim4/exim4.conf
ADD ./conf/mailname /etc/mailname
ADD ./conf/aliases /etc/aliases
ADD ./conf/nginx /etc/nginx/conf.d/rwky.net.conf
RUN npm -g install grunt-cli bower
ADD app/npm-shrinkwrap.json /home/app/
ADD app/package.json /home/app/
ADD app/bower.json /home/app/
RUN cd /home/app && npm install
RUN cd /home/app && bower --allow-root install
ADD app/ /home/app
RUN cd /home/app && grunt dist
EXPOSE 80 443

