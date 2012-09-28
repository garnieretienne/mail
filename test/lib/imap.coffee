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
    imap.on 'message:new', (message) ->
      expect(message.to[0].address).to.equal 'webmail.testing.dev@gmail.com'
    imap.connect this.imapSettings, (err, imapConnection) ->
      throw err if err
      imap.fetchSeqno imapConnection, '1:10', (messages) ->
        imapConnection.logout()
        done()
