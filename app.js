require('coffee-script');
var http = require('http');

var lib = require('./lib');

var app = lib.app;

http.createServer(app).listen(app.get('port'), function () {
  console.log("Express server listening on port " + app.get('port'));
});

module.exports = lib;
