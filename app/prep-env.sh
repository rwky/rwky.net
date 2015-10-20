#!/bin/bash
cd /home/app
bower install --allow-root
npm install
cp -a example-config config
npm -g install coffee-script
coffee -c config/config.coffee
grunt
