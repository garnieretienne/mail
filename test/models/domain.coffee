# Testing libraries
Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert

# Models
Domain = require('../../models/models').Domain

describe 'Domain', ->

  before (done) ->
    Testing.resetAllDatabases ->
      done()

  it 'should create a new domain', ->
    gmail = new Domain
      name: 'gmail.com'
    expect(gmail.name).to.equal 'gmail.com'

  it 'should save the domain in the database', (done) ->
    gmail = new Domain
      name: 'gmail.com'
    gmail.save (err) ->
      throw err if err
      expect(gmail.id).to.not.equal undefined
      done()

  it 'should load a domain from the database', (done) ->
    Domain.find {where: {name: 'gmail.com'}}, (err, domains) ->
      throw err if err
      expect(domains[0].name).to.equal 'gmail.com'
      done()
