Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
#Account = require '../../models/account'

# Models
Models   = require('../../models')
Account  = Models.Account

describe 'Account', ->

  before (done) ->
    @account = Account.new
      username: Testing.imapSettings.username
      password: Testing.imapSettings.password
    #this.account.findProvider =>
    done()

  it 'should retrieve the username (alias for email address) but not the password', ->
    expect(@account.emailAddress).to.equal Testing.imapSettings.username
    expect(@account.username).to.equal Testing.imapSettings.username
    expect(@account.password).to.equal Testing.imapSettings.password

  it 'should save the account in the database', (done) ->
    @account.save().success (account) ->
      expect(account.emailAddress).to.equal Testing.imapSettings.username
      expect(account.username).to.equal Testing.imapSettings.username
      expect(account.password).to.equal Testing.imapSettings.password
      done()
