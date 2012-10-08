Testing = require '../_helper.js'
request = require 'request'
app     = require '../../app'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
cheerio = require('cheerio')

describe 'Authentication', ->

  # Disconnect the current user
  disconnect = (cookieJar, callback) ->
    options = 
      followRedirect: false
      uri: "http://localhost:#{app.get('port')}/sessions"
      jar: cookieJar
    request.del options, (err, res, body) ->
      callback()

  # Act as if the user was athenticated
  authenticate = (callback) ->
    options = 
      followRedirect: false
      uri: "http://localhost:#{app.get('port')}/sessions"
      form: 
        username: Testing.imapSettings.username
        password: Testing.imapSettings.password
      jar: request.jar()
    request.post options, (err, res, body) ->
      jar = request.jar()
      cookie = request.cookie res.headers['set-cookie'][0]
      jar.add cookie
      callback disconnect, jar

  describe 'GET /login', ->

    describe 'show login interface', ->
      $ = null

      before (done) ->
        options = 
          followRedirect: false
          uri: "http://localhost:#{app.get('port')}/login"
        request options, (err, res, body) ->
          $ = cheerio.load(body);
          done()

      it 'has an username and password field', ->
        expect($('input[name="username"]').attr('name')).to.equal 'username'
        expect($('input[name="password"]').attr('name')).to.equal 'password'
        expect($('input[type="submit"]')).to.not.be.null

  describe 'POST /sessions', ->

    describe 'authenticate the user', ->

      it 'should authenticate the user', (done) ->
        authenticate (_disconnect, cookieJar) ->
          options = 
            followRedirect: false
            uri: "http://localhost:#{app.get('port')}/mail"
            jar: cookieJar
          request options, (err, res, body) ->
            expect(res.statusCode).to.equal 200
            _disconnect cookieJar, done

      it 'should not authenticate the user', (done) ->
        options =
          followRedirect: false
          uri: "http://localhost:#{app.get('port')}/sessions"
          form: 
            username: Testing.imapSettings.username
            password: 'wrongpassword'
          jar: request.jar()
        request.post options, (err, res, body) ->
          jar = request.jar()
          cookie = request.cookie res.headers['set-cookie'][0]
          jar.add cookie
          options = 
            jar: jar
            followRedirect: false
            uri: "http://localhost:#{app.get('port')}/mail"
          request options, (err, res, body) ->
            expect(res.statusCode).to.equal 302
            done()

      it 'should authenticate and disconnect the user', (done) ->

        authenticate (_disconnect, cookieJar) ->
          request {uri: "http://localhost:#{app.get('port')}/mail", followRedirect: false, jar: cookieJar}, (err, res, body) ->
            expect(res.statusCode).to.equal 200 # Connected
            _disconnect cookieJar, ->
              request {uri: "http://localhost:#{app.get('port')}/mail", followRedirect: false, jar: cookieJar}, (err, res, body) ->
                expect(res.statusCode).to.equal 302 # Disconnected
                done()

