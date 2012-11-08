# Testing libraries
Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert

# Sequelized Models
SequelizedModels = require(__dirname + '/../../models/sequelize/sequelizedModels')

# Models
Provider = require '../../models/provider'
Domain   = require '../../models/domain'

describe 'Association and Sync for Provider and Domain,', ->

  describe 'Provider', ->

    beforeEach (done) ->
      _this = @
      Provider.sync({force: true}).success ->
        Domain.sync({force: true}).success ->
          _this.provider = new Provider
            name: 'Local Mail'
            imap_host: 'localhost'
            imap_port: 993
            imap_secure: true
            smtp_host: 'localhost'
            smtp_port: 465
            smtp_secure: true
          done()

    it 'should retrive some attributes', ->
      expect(@provider.name).to.equal 'Local Mail'
      expect(@provider.imap_host).to.equal 'localhost'
      expect(@provider.smtp_host).to.equal 'localhost'

    it 'should save the provider into the database', (done) ->
      localProvider = @provider
      localProvider.save()
        .success (provider) ->
          expect(provider.name).to.equal localProvider.name
          expect(provider.imap_host).to.equal localProvider.imap_host
          expect(provider.imap_port).to.equal localProvider.imap_port
          expect(provider.imap_secure).to.equal localProvider.imap_secure
          expect(provider.smtp_host).to.equal localProvider.smtp_host
          expect(provider.smtp_port).to.equal localProvider.smtp_port
          expect(provider.smtp_secure).to.equal localProvider.smtp_secure
          done()

    it 'should add domains to the provider', (done) ->
      provider = @provider
      gmailDNS  = new Domain
        name: 'gmail.com'
      googleDNS = new Domain
        name: 'google.com'
      provider.setDomains([gmailDNS, googleDNS])
        .success ->
          provider.getDomains()
            .success (domains) ->
              expect(domains[0].name).to.equal 'gmail.com'
              expect(domains[1].name).to.equal 'google.com'
              done()
            .error (err) ->
              throw err
        .error (err) ->
          throw err

    it 'should retrieve the provider for a given domain', (done) ->
      provider = @provider
      provider.save().success ->
        gmailDNS  = new Domain
          name: 'gmail.com'
        googleDNS = new Domain
          name: 'google.com'
        provider.setDomains([gmailDNS, googleDNS])
          .success ->
            Domain.find where: {name: 'gmail.com'}, (gmailDNS) ->
              gmailDNS.getProvider()
                .success (sequelizedProvider) ->
                  provider = SequelizedModels.convert sequelizedProvider, Provider
                  expect(provider.name).to.equal 'Local Mail'
                  done()
                .error (err) ->
                  throw err   
          .error (err) ->
            throw err

    it 'should search for a provider given an email address', (done) ->
      provider = @provider
      provider.save().success ->
        gmailDNS  = new Domain
          name: 'gmail.com'
        googleDNS = new Domain
          name: 'google.com'
        provider.setDomains([gmailDNS, googleDNS])
          .success ->
            Provider.search 'testing@gmail.com', (provider) ->
              expect(provider.name).to.equal 'Local Mail'
              done()

    it "should search for an unknow provider and tell it didn't found anything", (done) ->
      Provider.search 'test@unknow.com', (provider) ->
        expect(provider).to.be.null
        done()