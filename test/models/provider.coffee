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

    before (done) ->
      Testing.resetAllDatabases ->
        done()

    beforeEach ->
      @provider = new Provider
        name: 'Local Mail'
        imapHost: 'localhost'
        imapPort: 993
        imapSecure: true
        smtpHost: 'localhost'
        smtpPort: 465
        smtpSecure: true

    it 'should retrieve some attributes', ->
      expect(@provider.name).to.equal 'Local Mail'
      expect(@provider.imapHost).to.equal 'localhost'
      expect(@provider.smtpHost).to.equal 'localhost'

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
                expect(provider.name).to.equal 'Local Mail'
                expect(provider.imapHost).to.equal 'localhost'
                provider.getDomains (err, retrievedDomains) ->
                  throw err if err
                  expect(retrievedDomains[0].name).to.equal 'gmail.com'
                  expect(retrievedDomains[1].name).to.equal 'google.com'
                  done()

    it 'should retrieve the provider for a given domain', (done) ->
      Domain.find {where: {name: 'gmail.com'}}, (err, results) ->
        throw err if err
        gmailDNS = results[results.length-1]
        gmailDNS.getProvider (err, provider) ->
          expect(provider.name).to.equal 'Local Mail'
          done()