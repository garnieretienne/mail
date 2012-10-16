Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
IMAP = require '../../lib/imap'

describe 'IMAP', ->
  
  before ->
    this.imapSettings = Testing.imapSettings

  it 'should connect an IMAP account', (done) ->
    imap = new IMAP this.imapSettings
    imap.connect (err) ->
      throw err if err
      imap.emit 'logout'
      done()

  it 'should logout from an IMAP account', (done) ->
    imap = new IMAP this.imapSettings
    imap.connect (err) ->
      throw err if err
      imap.emit 'logout', ->
        expect(imap.imap._state.requests[0].cmd).to.equal 'LOGOUT'
        done()

  it 'should open the INBOX mailbox after connected', (done) ->
    imap = new IMAP this.imapSettings
    imap.connect (err) ->
      imap.open 'INBOX', (err, box) ->
        throw err if err
        expect(box.name).to.equal 'INBOX'
        imap.emit 'logout'
        done()

  # Need for authenticated? Authenticate if no error ?
  it 'should authenticate an user using his IMAP credentials', (done) ->
    imapSettings = 
      host:   this.imapSettings.host
      port:   this.imapSettings.port
      secure: this.imapSettings.secure
    imap = new IMAP imapSettings
    IMAP.authenticate imapSettings, this.imapSettings.username, 'wrongpassword', (err, authenticated) ->
      expect(err.code).to.equal 'AUTHENTICATIONFAILED'
      expect(authenticated).to.be.false
    IMAP.authenticate imapSettings, this.imapSettings.username, this.imapSettings.password, (err, authenticated) ->
      expect(err).to.be.null
      expect(authenticated).to.be.true
      done()

  it 'should fetch headers and structure for a message range', (done) ->
    imap = new IMAP this.imapSettings
    imap.on 'fetchHeaders:data', (message) ->
      expect(message.to[0]).to.equal 'webmail.testing.dev@gmail.com'
      expect(message.uid).to.be.not.null
    imap.connect (err) ->
      throw err if err
      imap.open 'INBOX', (err) ->
        throw err if err
        imap.fetchHeaders '1:10', ->
          imap.emit 'logout'
          done()