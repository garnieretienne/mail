// Set up node in test environment
process.env.NODE_ENV = 'test';

// Allow coffee script for testing
require('coffee-script');

var Testing;

Testing = {
  imapSettings: {
    username: 'webmail.testing.dev@gmail.com',
    password: 'testing',
    host: 'localhost',
    port: 993,
    secure: true
  }
};

module.exports = Testing;