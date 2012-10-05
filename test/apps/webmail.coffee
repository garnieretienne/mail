request = require 'request'
app     = require '../../app'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
cheerio = require('cheerio')

describe 'Webmail', ->
  
  # Disconnect the current user
  disconnect = (cookieJar, callback) ->
    options = 
      followRedirect: false
      uri: "http://localhost:#{app.get('port')}/sessions"
    request.del options, (err, res, body) ->
      callback()

  # Act as if the user was athenticated
  authenticate = (callback) ->
    options = 
      followRedirect: false
      uri: "http://localhost:#{app.get('port')}/sessions"
      form: 
        username: 'webmail.testing.dev@gmail.com'
        password: 'imnotstrong'
    request.post options, (err, res, body) ->
      jar = request.jar()
      cookie = request.cookie res.request.headers.cookie
      jar.add cookie
      callback disconnect, jar

  describe 'GET /', ->

    describe 'should redirect the user to /mail', ->
      options = 
        followRedirect: false
        uri: "http://localhost:#{app.get('port')}/"
      request options, (err, res, body) ->
        expect(res.headers.location).to.equal "//localhost:#{app.get('port')}/mail"
        expect(res.statusCode).to.equal 302

  describe 'GET /mail', ->

    describe '(non-authenticated) redirect the user to the login page', ->

      it 'get the login page after redirection', ->
        options = 
          followRedirect: true
          uri: "http://localhost:#{app.get('port')}/mail"
        request options, (err, res, body) ->
          $ = cheerio.load(body)
          expect($('title').text()).to.equal 'Mail - Login'


    describe '(authenticated) show webmail user interface', ->
      $ = null

      before (done) ->
        authenticate (_disconnect, cookieJar) ->
          options =
            uri: "http://localhost:#{app.get('port')}/mail"
            followRedirect: false
            jar: cookieJar
          request options, (err, res, body) ->
            expect(res.statusCode).to.equal 200 # Connected
            $ = cheerio.load(body)
            _disconnect cookieJar, done

      it 'has title', ->
        expect($('title').text()).to.equal 'Mail'
      it 'has header', ->
        expect($('#header').length).to.equal 1
      it 'has menu', ->
        expect($('#menu').length).to.equal 1
        expect($('#menu #mailbox-list').length).to.equal 1
        expect($('#menu #actions').length).to.equal 1
      it 'has message list', ->
        expect($('#message-list').length).to.equal 1
      it 'has message area', ->
        expect($('#message').length).to.equal 1
      it 'has the username', ->
        expect($('#user').text()).to.equal 'webmail.testing.dev@gmail.com'