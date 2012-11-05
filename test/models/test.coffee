Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
TestObject = require '../../models/test'

describe 'Test', ->

  it 'should found foo instance vriable', ->
    test = new TestObject()
    expect(test.foo).to.equal 'bar'

  it 'should return "Hello You"', ->
    text = TestObject.helloYou()
    expect(text).to.equal 'Hello You'

  it 'should return Hello World', ->
    test = new TestObject()
    text = test.helloWorld()
    expect(text).to.equal 'Hello World'

  it 'should save the TestObject', (done) ->
    test = new TestObject()
    test.save()
      .success (testObject) ->
        expect(testObject.foo).to.equal 'bar'
        done()
