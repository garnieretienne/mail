express = require 'express'
assert  = require 'assert'
request = require 'request'
app     = require '../../app'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
cheerio = require('cheerio')

describe 'Webmail', ->

  describe 'GET /', ->

    describe 'show webmail user interface', ->
      $ = null

      before (done) ->
        options = 
          uri: "http://localhost:#{app.get('port')}/"
        request options, (err, res, body) ->
          $ = cheerio.load(body);
          done()

      it 'has title', ->
        console.log $('title').text();
        expect($('title').text()).to.equal 'Mail'
