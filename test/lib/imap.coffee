should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
IMAP = require '../../lib/imap'

describe 'IMAP', ->
  
  before ->
    this.imapSettings = 
      username: 'webmail.testing.dev@gmail.com'
      password: 'imnotstrong'
      host:     'imap.gmail.com'
      port:     993
      secure:   true

  it 'should connect an IMAP account, select the INBOX and listen for events', (done) ->
    imap = new IMAP()
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imapConnection.logout() if imapConnection
      done()

  it 'should fetch messages using seqno', (done) ->
    imap = new IMAP()
    imap.on 'message:new', (parsedMessage, imapFields) ->
      expect(imapFields.seqno).to.equal 1
      expect(imapFields.uid).to.equal 60
      expect(imapFields.date).to.equal '12-May-2012 15:09:48 +0000'
      expect(imapFields.flags[0]).to.equal 'Seen'
      expect(parsedMessage.to[0].address).to.equal 'webmail.testing.dev@gmail.com'
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imap.fetchNewMessage imapConnection, '1', (messages) ->
        imapConnection.logout()
        done()

  it 'should authenticate an user using his IMAP credentials', ->
    IMAP.authenticate this.imapSettings.username, 'wrongpassword', (err, authenticated) ->
      expect(err.message).to.equal 'Invalid credentials (Failure)'
      expect(authenticated).to.be.false
    IMAP.authenticate this.imapSettings.username, this.imapSettings.password, (err, authenticated) ->
      expect(err).to.be.null
      expect(authenticated).to.be.true