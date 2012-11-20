// Set up node in test environment
process.env.NODE_ENV = 'test';

// Allow coffee script for testing
require('coffee-script');

// Database client
var client = require(__dirname+'/../config/database.coffee')();

var Testing;

Testing = {
  imapSettings: {
    username: 'webmail.testing.dev@gmail.com',
    password: 'testing',
    host: 'localhost',
    port: 993,
    secure: true
  },
  resetDatabase: function(tableName, callback){
    var query = client.query("TRUNCATE " + tableName + " CASCADE", function(err, result) {
      if (err) {
        throw err;
      }
      callback()
    });
  },
  resetAllDatabases: function(callback){
    var resetDatabase = this.resetDatabase;
    resetDatabase('messages', function(){
      resetDatabase('mailboxes', function(){
        resetDatabase('accounts', function(){
          resetDatabase('domains', function(){
            resetDatabase('providers', function(){
              callback();
            });
          });
        });
      });
    });
  }
};

module.exports = Testing;