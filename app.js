require('coffee-script');
var http = require('http');
var express = require('express');
var app = express();

app.set('port', 3000);
app.use(express.static(__dirname + "/public"));

http.createServer(app).listen(app.get('port'), function () {
  console.log("Express server listening on port " + app.get('port'));
});
