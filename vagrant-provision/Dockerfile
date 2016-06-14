FROM rwky/phusion-passenger:latest 
MAINTAINER Rowan Wookey <admin@rwky.net>
RUN apt-get update && \
apt-get -y install nodejs && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
rm -rf /etc/service/nginx/down && \
rm -rf /etc/service/rsyslog/down && \
rm -f /etc/service/sshd/down && \
touch /etc/service/cron/down && \
rm -rf /home/app && ln -sf /vagrant/app /home/app && \
npm -g install grunt-cli bower
COPY ssh_key /root/.ssh/authorized_keys
COPY nginx /etc/nginx/conf.d/default.conf
EXPOSE 80 443 22
WORKDIR /vagrant/app
