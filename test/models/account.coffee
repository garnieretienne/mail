Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert
util = require('util')

# Sequelized Models
SequelizedModels   = require(__dirname + '/../../models/sequelize/sequelizedModels')

# Models
Account  = require '../../models/account'
Provider = require '../../models/provider'
Domain   = require '../../models/domain'
Mailbox  = require '../../models/mailbox'

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

  # it 'should load an account from the database whith no unpersistent attributes', (done) ->
  #  @account.save()
  #    .success ->
  #      Account.find where: {emailAddress: Testing.imapSettings.username}, (account) ->
  #        expect(account).to.be.not.null
  #        expect(account.emailAddress).to.equal Testing.imapSettings.username
  #        expect(account.username).to.equal undefined
  #        expect(account.password).to.equal undefined
  #        done()

  # it 'should test inheritance', (done) ->
  #   _this = @
  #   account1 = new Account
  #     username: 'test@gmail.com'
  #     password: 'testing'
  #   expect(account1.isNewRecord).to.be.true
  #   expect(@account.isNewRecord).to.be.true
  #   @account.save()
  #     .success ->
  #       expect(_this.account.isNewRecord).to.be.false
  #       expect(account1.isNewRecord).to.be.true
  #       Account.find where: {emailAddress: Testing.imapSettings.username}, (account2) ->
  #         expect(account1.isNewRecord).to.be.true
  #         expect(account2.isNewRecord).to.be.false
  #         account2.authenticate ->
  #           done()

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
  #     Account.find where: {emailAddress: Testing.imapSettings.username}, (account) ->
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
  #         account.getProvider().success (sequelizedProvider) ->
  #           provider = SequelizedModels.convert(sequelizedProvider, Provider)
  #           expect(provider.name).to.equal 'Local Mail'
  #           done()

  it 'should list the account mailboxes (from the IMAP server)', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.getIMAPMailboxes (err, mailboxes) ->
        thow err if err
        expect(mailboxes[0].name).to.equal 'Trash'
        expect(mailboxes[0].selectable).to.be.true
        expect(mailboxes[1].name).to.equal 'INBOX'
        expect(mailboxes[1].selectable).to.be.true
        done()

  it 'should suscribe to a mailbox', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.save().success ->
        _this.account.getIMAPMailboxes (err, mailboxes) ->
          SuscribedMailbox = mailboxes[0]
          _this.account.setMailboxes([mailboxes[0], mailboxes[1]])
            .success ->
              _this.account.getMailboxes()
                .success (SequelizedMailboxes) ->
                  mailbox = SequelizedModels.convert(SequelizedMailboxes[0], Mailbox)
                  expect(mailbox.name).to.equal SuscribedMailbox.name
                  done()
            .error (err) ->
              throw err if err

  #it 'should fully synchronize the account', ->