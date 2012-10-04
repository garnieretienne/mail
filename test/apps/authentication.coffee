request = require 'request'
app     = require '../../app'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
cheerio = require('cheerio')

describe 'Authentication', ->

  describe 'GET /login', ->

    describe 'show login interface', ->
      $ = null

      before (done) ->
        options = 
          uri: "http://localhost:#{app.get('port')}/login"
        request options, (err, res, body) ->
          $ = cheerio.load(body);
          done()

      it 'has an username and password fied', ->
        expect($('input[name="username"]').attr('name')).to.equal 'username'
        expect($('input[name="password"]').attr('name')).to.equal 'password'
        expect($('input[type="submit"]')).to.not.be.null

  describe 'POST /sessions', ->

    describe 'authenticate the user', ->

      it 'should authenticate the user'

      it 'should not authenticate the user'