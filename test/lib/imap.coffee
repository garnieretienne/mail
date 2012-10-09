Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
IMAP = require '../../lib/imap'

describe 'IMAP', ->
  
  before ->
    this.imapSettings = Testing.imapSettings

  it 'should connect an IMAP account, select the INBOX and listen for events', (done) ->
    imap = new IMAP()
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imapConnection.logout() if imapConnection
      done()

  it 'should fetch messages using seqno', (done) ->
    imap = new IMAP()
    imap.on 'message:new', (message) ->
      expect(message.seqno).to.equal 1
      expect(message.uid).to.equal 1
      expect(message.date).to.equal '08-Oct-2012 15:54:37 +0200'
      expect(message.to[0]).to.equal 'webmail.testing.dev@gmail.com'
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imap.fetchNewMessage imapConnection, '1', (messages) ->
        imapConnection.logout()
        done()

  it 'should authenticate an user using his IMAP credentials', (done) ->
    imapServer = 
      host: this.imapSettings.host
      port: this.imapSettings.port
      secure: this.imapSettings.secure
    IMAP.authenticate imapServer, this.imapSettings.username, 'wrongpassword', (err, authenticated) ->
      expect(err.code).to.equal 'AUTHENTICATIONFAILED'
      expect(authenticated).to.be.false
    IMAP.authenticate imapServer, this.imapSettings.username, this.imapSettings.password, (err, authenticated) ->
      expect(err).to.be.null
      expect(authenticated).to.be.true
      done()

  it 'should fetch headers and structure for a message range', (done) ->
    imap = new IMAP()
    imap.on 'fetchHeaders:data', (message) ->
      expect(message.to[0]).to.equal 'webmail.testing.dev@gmail.com'
      expect(message.uid).to.be.not.null
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imap.fetchHeaders imapConnection, '1:10', ->
        imapConnection.logout()
        done()