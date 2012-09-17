
/**
 * Module dependencies.
 */

// Enable coffee language
require('coffee-script');

var express = require('express')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static  (path.join(__dirname, 'public')));

  // Enable rails style asset pipeline
  app.use(require('connect-assets')());
  css.root = 'stylesheets'
  js.root  = 'javascripts'
});

app.configure('development', function(){
  app.use(express.errorHandler());

  // Allow connect-assets to access included libraries in development
  app.use(express.static  (path.join(__dirname, './')));
});

// Routes
require('./apps/webmail/routes')(app);
require('./apps/api/routes')(app);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
