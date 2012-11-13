# Testing libraries
Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert

# Models
Models   = require(__dirname+'/../../models/models')
Provider = Models.Provider
Domain   = Models.Domain

describe 'Association and Sync for Provider and Domain,', ->

  describe 'Provider', ->

    beforeEach ->
      @provider = new Provider
        name: 'Local Mail'
        imap_host: 'localhost'
        imap_port: 993
        imap_secure: true
        smtp_host: 'localhost'
        smtp_port: 465
        smtp_secure: true

    it 'should retrieve some attributes', ->
      expect(@provider.name).to.equal 'Local Mail'
      expect(@provider.imap_host).to.equal 'localhost'
      expect(@provider.smtp_host).to.equal 'localhost'

    it 'should save the provider into the database', (done) ->
      _this = @
      @provider.save (err) ->
        throw err if err
        expect(_this.provider.id).to.not.equal undefined
        done()

    it 'should add domains to the provider', (done) ->
      _this = @
      gmailDNS  = new Domain
        name: 'gmail.com'
      googleDNS = new Domain
        name: 'google.com'
      @provider.setDomains [gmailDNS, googleDNS], (domains) ->
        expect(domains[0].name).to.equal 'gmail.com'
        expect(domains[1].name).to.equal 'google.com'
        _this.provider.save ->
          gmailDNS.save ->
            googleDNS.save ->
              Provider.find _this.provider.id, (err, provider) ->
                provider.getDomains (err, retrievedDomains) ->
                  throw err if err
                  expect(retrievedDomains[0].name).to.equal 'gmail.com'
                  expect(retrievedDomains[1].name).to.equal 'google.com'
                  done()

    it 'should retrieve the provider for a given domain', (done) ->
      Domain.find {name: 'gmail.com'}, (err, results) ->
        throw err if err
        gmailDNS = results[results.length-1]
        gmailDNS.getProvider (err, provider) ->
          expect(provider.name).to.equal 'Local Mail'
          done()

    # TODO: parse email address to get the domain name in account
    # it 'should search for a provider given an email address', (done) ->
    #   provider = @provider
    #   provider.save().success ->
    #     gmailDNS  = new Domain
    #       name: 'gmail.com'
    #     googleDNS = new Domain
    #       name: 'google.com'
    #     provider.setDomains([gmailDNS, googleDNS])
    #       .success ->
    #         Provider.search 'testing@gmail.com', (provider) ->
    #           expect(provider.name).to.equal 'Local Mail'
    #           done()

    # it "should search for an unknow provider and tell it didn't found anything", (done) ->
    #   Provider.search 'test@unknow.com', (provider) ->
    #     expect(provider).to.be.null
    #     done()