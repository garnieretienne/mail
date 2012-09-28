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
