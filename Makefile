test:
	mocha -r app.js --compilers coffee:coffee-script test/github.coffee

test-all:
	mocha -r app.js --compilers coffee:coffee-script

.PHONY: test test-all
