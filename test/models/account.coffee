Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert

# Models
Models   = require(__dirname+'/../../models/models')
Account  = Models.Account
Provider = Models.Provider
Domain   = Models.Domain
Mailbox  = Models.Mailbox

describe 'Account', ->

  before (done) ->
    _this = @
    Testing.resetAllDatabases ->
      _this.account = new Account
        username: Testing.imapSettings.username
        password: Testing.imapSettings.password
      gmailDNS = new Domain
        name: 'gmail.com'
      _this.provider = new Provider
        name: 'Local Mail'
        imapHost: 'localhost'
        imapPort: 993
        imapSecure: true
        smtpHost: 'localhost'
        smtpPort: 465
        smtpSecure: true
      _this.provider.setDomains [gmailDNS], ->
        _this.provider.save ->
          gmailDNS.save ->
            done()

  it 'should retrieve the username (alias for email address) but not the password', ->
    expect(@account.emailAddress).to.equal Testing.imapSettings.username
    expect(@account.username).to.equal Testing.imapSettings.username
    expect(@account.password).to.equal Testing.imapSettings.password

  it 'should save the account in the database', (done) ->
    _this = @
    @account.setProvider @provider, (provider) ->
      _this.account.save (err) ->
        throw err if err
        expect(_this.account.id).to.not.equal undefined
        done()

  it 'should load an account from the database whith no unpersistent attributes', (done) ->
    Account.find {emailAddress: Testing.imapSettings.username}, (err, results) ->
      throw err if err
      account = results[results.length-1]
      expect(account).to.be.not.null
      expect(account.emailAddress).to.equal Testing.imapSettings.username
      expect(account.username).to.equal undefined
      expect(account.password).to.equal undefined
      done()

  it 'should find the provider for a new created account', (done) ->
    _this = @
    domainName = @account.getDomainName()
    expect(domainName).to.equal 'gmail.com'
    Domain.find {name: 'gmail.com'}, (err, results) ->
      throw err if err
      domain = results[results.length-1]
      expect(domain.name).to.equal 'gmail.com'
      domain.getProvider (err, provider) ->
        throw err if err
        expect(provider.name).to.equal 'Local Mail'
        _this.account.setProvider provider, ->
          expect(_this.account.provider.id).to.equal provider.id
          done()

  it 'should NOT find the provider for this account', (done) ->
    account = new Account
      username: 'nobody@nowhere.com'
      password: 'ohyeah'
    domainName = account.getDomainName()
    Domain.find {name: domainName}, (err, domains) ->
      throw err if err
      expect(domains).to.be.empty
      done()

  it "should try to authenticate the account with given credentials", (done) ->
    @account.authenticate (err, authenticated) ->
      throw err if err
      expect(authenticated).to.be.true
      done()

  it 'should connect the account', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      expect(_this.account.imap.imap._state.status).to.equal 2
      _this.account.imap.imap.logout ->
        done()

  it 'should connect to the account and select the INBOX mailbox', (done) ->
    _this = @
    mailbox = new Mailbox
      name: 'INBOX'
      uidValidity: 123456789
    @account.connect (err) ->
      throw err if err
      _this.account.select mailbox, (err) ->
        throw err if err
        expect(_this.account.selectedMailbox.name).to.equal 'INBOX'
        _this.account.imap.imap.logout ->
          done()

  it 'should disconnect the account', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.disconnect ->
        requests  = _this.account.imap.imap._state.requests
        lastIndex = requests.length - 1
        expect(requests[lastIndex].cmd).to.equal 'LOGOUT'
        done()

  it 'should list the account mailboxes (from the IMAP server)', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.getIMAPMailboxes (err, mailboxes) ->
        thow err if err
        expect(mailboxes[0].name).to.equal 'Trash'
        expect(mailboxes[0].selectable).to.be.true
        expect(mailboxes[1].name).to.equal 'Parent'
        expect(mailboxes[1].selectable).to.be.true
        expect(mailboxes[2].name).to.equal 'Children'
        expect(mailboxes[2].selectable).to.be.true
        expect(mailboxes[2].mailbox.name).to.equal 'Parent'
        expect(mailboxes[3].name).to.equal 'INBOX'
        expect(mailboxes[3].selectable).to.be.true
        done()

  it 'should suscribe to a mailbox', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.getIMAPMailboxes (err, mailboxes) ->
        thow err if err
        mailbox = null
        for _mailbox in mailboxes
          mailbox = _mailbox if _mailbox.name == 'INBOX'
        mailbox.setAccount _this.account, ->
          expect(mailbox.account.emailAddress).to.equal Testing.imapSettings.username
          mailbox.save ->
            expect(mailbox.id).to.not.equal undefined
            done()

  it 'should fully synchronize the account', (done) ->
    _this = @
    @account.connect (err) ->
      throw err if err
      _this.account.getMailboxes (err, mailboxes) ->
        throw err if err
        inbox = mailboxes[0]
        _this.account.select inbox, (err) ->
          throw err if err
          _this.account.on 'message:new', (message) ->
            expect(message.subject).to.not.equal undefined
            expect(message.subject).to.not.be.null
          _this.account.synchronize {type: 'full'}, (err) ->
            done()