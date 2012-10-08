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

  it "should try to authenticate the account withe the given credentials", (done) ->
    this.account.authenticate (err, authenticated) ->
      expect(err).to.be.null
      expect(authenticated).to.be.true
      done()