NPM = npm

JS_FILES = app.js routes/*.js public/js/main.js

INOTIFY = inotifywait -q -e modify -e move_self -e move -e create

all:
	$(MAKE) version
	$(MAKE) npm 
	$(MAKE) lint
	$(MAKE) watch

dist:
	$(MAKE) version
	$(MAKE) npm

version:
	echo "module.exports = '$$(date -u '+%s')'" > version.js 

npm:
	npm ci

lint:
	npx eslint $(JS_FILES) --fix

restart:
	docker exec rwky-net-docker passenger-config restart-app --ignore-passenger-not-running /

watch:
	$(INOTIFY) $(JS_FILES); \
	$(MAKE) restart; \
	$(MAKE) $(@)

.PHONY: watch restart lint npm version dist all


