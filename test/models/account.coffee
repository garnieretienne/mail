#assert = require("assert")
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
Account = require '../../models/account'

describe 'Account', ->

  before ->
    this.account = new Account
      username: 'webmail.testing.dev@gmail.com'
      password: 'imnotstrong'

  it 'should retrive the username but not the password', ->
    expect(this.account.username).to.equal 'webmail.testing.dev@gmail.com'
    expect(this.account.password).to.equal undefined

  it 'should connect the account INBOX', (done) ->
    expect(this.account.imap.server).to.equal 'imap.gmail.com'
    expect(this.account.imap.port).to.equal '993'
    expect(this.account.imap.tls).to.be.true
    this.account.connect done