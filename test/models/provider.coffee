Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
Provider = require '../../models/provider'

describe 'Provider', ->

  before ->
    @provider = new Provider
      name: 'gmail'
      domains: ['gmail.com', 'google.com']
      imap:
        host: 'localhost'
        port: 993
        secure: true
      smtp:
        host: 'localhost'
        port: 465
        secure: true

  it 'should retrive some attributes', ->
    gmail = @provider
    expect(gmail.name).to.equal 'gmail'
    expect(gmail.imap.host).to.equal 'localhost'
    expect(gmail.smtp.host).to.equal 'localhost'

  it 'should save the provider into the database', (done) ->
    gmail = @provider
    gmail.save (err) ->
      throw err if err
      done()

  it 'should load the provider from the database', (done) ->
    Provider.load 'gmail', (err, gmail) ->
      throw err if err
      expect(gmail.name).to.equal 'gmail'
      expect(gmail.imap.host).to.equal 'localhost'
      expect(gmail.smtp.host).to.equal 'localhost'
      done()

  it 'should tell if the provider was not found in the database', (done) ->
    Provider.load 'unknow', (err, unknow) ->
      expect(err.status_code).to.equal 404
      expect(unknow).to.be.empty
      done()

  it 'should search for the provider from the email address', (done) ->
    Provider.search 'test@gmail.com', (err, gmail) ->
      throw err if err
      expect(gmail.name).to.equal 'gmail'
      expect(gmail.imap.host).to.equal 'localhost'
      expect(gmail.smtp.host).to.equal 'localhost'
      done()

  it "should search for an unknow provider and tell it didn't found anything", (done) ->
    Provider.search 'test@unknow.com', (err, unknow) ->
      throw err if err
      expect(unknow).to.be.empty
      done()  