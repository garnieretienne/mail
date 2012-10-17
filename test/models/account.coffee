Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
Account = require '../../models/account'

describe 'Account', ->

  before ->
    this.account = new Account
      username: Testing.imapSettings.username
      password: Testing.imapSettings.password

  it 'should retrive the username but not the password', ->
    expect(this.account.username).to.equal 'webmail.testing.dev@gmail.com'
    expect(this.account.password).to.equal undefined

  it 'should connect the account INBOX', (done) ->
    expect(this.account.imap.host).to.equal 'localhost'
    expect(this.account.imap.port).to.equal '993'
    expect(this.account.imap.secure).to.be.true
    this.account.connect done

  it "should try to authenticate the account with given credentials", (done) ->
    this.account.authenticate (err, authenticated) ->
      expect(err).to.be.null
      expect(authenticated).to.be.true
      done()

  it 'should fully synchronize the account', (done) ->
    _this = this.account
    total = 0
    
    this.account.on 'message:new', (message) ->
      expect(message.seqno).to.be.below total+1

    this.account.connect (err) ->
      throw err if err
      _this.select 'INBOX', (err, mailbox) ->
        throw err if err
        total = _this.mailbox.messages.total
        settings = 
          type: 'full'
        sync = _this.synchronize settings
        sync.on 'error', (error) ->
          throw err if err
        sync.on 'end', ->
          done()

  it 'should disconnect the account', (done) ->
    account = this.account
    account.connect (err) ->
      throw err if err
      account.disconnect ->
        requests  = account.imap.imap._state.requests
        lastIndex = requests.length - 1
        expect(requests[lastIndex].cmd).to.equal 'LOGOUT'
        done()