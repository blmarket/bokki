server:
	nodemon -e ".js|.coffee" -x "nodejs"

test:
	mocha -r app.js --compilers coffee:coffee-script test/github.coffee

test-all:
	mocha -r app.js --compilers coffee:coffee-script

.PHONY: server test test-all
