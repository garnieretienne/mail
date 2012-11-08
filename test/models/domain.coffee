# Testing libraries
Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert

# Models
Domain = require '../../models/domain'

describe 'Domain', ->

  it 'should create a new domain', ->
    gmail = new Domain
      name: 'gmail.com'
    expect(gmail.name).to.equal 'gmail.com'

  it 'should save the domain in the database', (done) ->
    gmail = new Domain
      name: 'gmail.com'
    gmail.save()
      .success (domain) ->
        expect(domain.name).to.equal 'gmail.com'
        done()
      .error (err) ->
        throw err

  it 'should load a domain from the database', (done) ->
    Domain.find where: {name: 'gmail.com'}, (domain) ->
      expect(domain.name).to.equal 'gmail.com'
      done()
