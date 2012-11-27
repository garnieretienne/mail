
/**
 * Module dependencies.
 */

// Enable coffee language
require('coffee-script');

var express = require('express')
  , http = require('http')
  , path = require('path')
  , socketIO = require('socket.io')
  , RedisStore = require('connect-redis')(express)
  , sequelize = require(__dirname+'/config/database')

// Module.export is needed for testing
var app = module.exports = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('25c5f3e148c80d34de2c006699e87a7f'));
  app.use(express.session({ 
    store: new RedisStore(),
    key: 'mail_session'
  }));
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

app.configure('test', function(){
  app.set('port', 3001);
});

// Socket.io
var server = http.createServer(app);
var io = socketIO.listen(server);

// Routes
require('./apps/authentication/routes')(app);
require('./apps/webmail/routes')(app, io);

// App
server.listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});