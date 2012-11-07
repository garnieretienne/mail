Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert

# Models
Account  = require '../../models/account'
Provider = require '../../models/provider'
Domain   = require '../../models/domain'

describe 'Account', ->

  before (done) ->
    _this = @
    Domain.sync({force: true}).success ->
      Provider.sync({force: true}).success ->
        gmailDNS = new Domain
          name: 'gmail.com'
        _this.provider = new Provider
          name: 'Local Mail'
          imap_host: 'localhost'
          imap_port: 993
          imap_secure: true
          smtp_host: 'localhost'
          smtp_port: 465
          smtp_secure: true
        _this.provider.save()
          .success ->
            _this.provider.setDomains([gmailDNS])
              .success ->
                done()
              .error (err) ->
                throw err
          .error (err) ->
            throw err

  beforeEach (done) ->
    _this = @
    Account.sync({force: true}).success ->
      _this.account = new Account
        username: Testing.imapSettings.username
        password: Testing.imapSettings.password
      done()

  # it 'should retrieve the username (alias for email address) but not the password', ->
  #   expect(@account.emailAddress).to.equal Testing.imapSettings.username
  #   expect(@account.username).to.equal Testing.imapSettings.username
  #   expect(@account.password).to.equal Testing.imapSettings.password

  # it 'should save the account in the database', (done) ->
  #   @account.save()
  #     .success (account) ->
  #       expect(account.emailAddress).to.equal Testing.imapSettings.username
  #       expect(account.username).to.equal Testing.imapSettings.username
  #       expect(account.password).to.equal Testing.imapSettings.password
  #       done()
  #     .error (err) ->
  #       throw err

  it 'should load an account from the database whith no unpersistent attributes', (done) ->
    @account.save()
      .success ->
        Account.find where: {emailAddress: Testing.imapSettings.username}, (account) ->
          expect(account).to.be.not.null
          expect(account.emailAddress).to.equal Testing.imapSettings.username
          expect(account.username).to.equal undefined
          expect(account.password).to.equal undefined
          done()

  it 'should test inheritance', (done) ->
    account3 = new Account
      username: 'test@gmail.com'
      password: 'testing'
    expect(account3.isNewRecord).to.be.true
    expect(@account.isNewRecord).to.be.true
    @account.save()
      .success ->
        Account.find where: {emailAddress: Testing.imapSettings.username}, (account1) ->
          expect(account1.isNewRecord).to.be.false
          account2 = new Account
            username: 'test@gmail.com'
            password: 'testing'
          expect(account2.isNewRecord).to.be.true
          done()

  # it 'should find the provider for this account', (done) ->
  #   @account.findProvider (found, provider) ->
  #     expect(found).to.be.true
  #     expect(provider.name).to.equal 'Local Mail'
  #     done()

  # it 'should NOT find the provider for this account', (done) ->
  #   account = new Account
  #     username: 'nobody@nowhere.com'
  #     password: 'ohyeah'
  #   account.findProvider (found, provider) ->
  #     expect(found).to.be.false
  #     expect(provider).to.be.null
  #     done()

  # it "should try to authenticate the account with given credentials", (done) ->
  #   @account.authenticate (err, authenticated) ->
  #     throw err if err
  #     expect(authenticated).to.be.true
  #     done()

  # it 'should connect the account INBOX', (done) ->
  #   _this = @
  #   @account.connect (err) ->
  #     throw err if err
  #     expect(_this.account.selectedMailbox.name).to.equal 'INBOX'
  #     _this.account.imap.imap.logout ->
  #       done()

  # it 'should disconnect the account', (done) ->
  #   _this = @
  #   @account.connect (err) ->
  #     throw err if err
  #     _this.account.disconnect ->
  #       requests  = _this.account.imap.imap._state.requests
  #       lastIndex = requests.length - 1
  #       expect(requests[lastIndex].cmd).to.equal 'LOGOUT'
  #       done()

  # it "should cache the account on first connection", (done) ->
  #   _this = @
  #   @account.connect (err) ->
  #     throw err if err
  #     Account.find(where: {emailAddress: Testing.imapSettings.username}).success (account) ->
  #       expect(account).to.be.not.null
  #       expect(account.emailAddress).to.equal Testing.imapSettings.username
  #       account.getProvider().success (provider) ->
  #         expect(provider).to.not.be.null
  #         _this.account.disconnect ->
  #           done()

  # it "should test if the account is cached, load it and retrieve the provider", (done) ->
  #   _this = @
  #   Account.find where: {emailAddress: Testing.imapSettings.username}, (account) ->
  #     expect(account).to.be.null
  #     _this.account.connect (err) ->
  #       throw err if err
  #       Account.find where: {emailAddress: Testing.imapSettings.username}, (account) ->
  #         expect(account).to.be.not.null
  #         expect(account.ProviderId).to.be.not.null
  #         account.username = Testing.imapSettings.username
  #         account.password = Testing.imapSettings.password
  #         account.authenticate ->
  #           account.getProvider().success (provider) ->
  #             console.log provider
  #             done()

  #it 'should list the account mailboxes', ->

  #it 'should list the account suscribed mailboxes', ->

  #it 'should fully synchronize the account', ->