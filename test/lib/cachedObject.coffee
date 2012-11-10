Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert

CachedObject = require(__dirname + '/../../lib/cachedObject.coffee')

# Custom class for testing, inherit from CachedObject class
# ---------------------------------------------------------

class CustomClass
  
  constructor: ->
    @cachedAttributes = ['name', 'goal'] # Attributes to be saved into database
    @name = 'Hello'
    @goal = 'World'
    @foo  = 'bar'

  helloWorld: ->
    return "Hello World"

CachedObject.extends(CustomClass)

class AnotherClass
  @hasOne: [CustomClass]

  constructor: ->
    @cachedAttributes = ['number']
    @number = 12344

CachedObject.extends(AnotherClass)

# ---------------------------------------------------------

describe 'Cached Objects >', ->

  describe 'Pure Cached Object >', ->

    it 'should create a cached object', ->
      cachedObject = new CachedObject()

    it 'should save a cachedObject', (done) ->
      cachedObject = new CachedObject()
      cachedObject.name = 'Cached Object'
      cachedObject.goal = 'Manage cache for object attributes'
      cachedObject.cachedAttributes = ['name', 'goal']
      expect(cachedObject.id).to.equal undefined
      cachedObject.save (err) ->
        throw err if err
        expect(cachedObject.id).to.not.equal undefined
        done()

    it 'should find a cached object using its ID', (done) ->
      object = new CachedObject()
      object.name = 'Cached Object'
      object.goal = 'Manage cache for object attributes'
      object.cachedAttributes = ['name', 'goal']
      object.save ->
        CachedObject.find object.id, (err, cachedObject) ->
          throw err if err
          expect(cachedObject.name).to.equal 'Cached Object'
          done()

  describe 'Object inherited from Cached Object >', ->

    it 'should inherit from a Cached Object', ->
     expect(CustomClass.prototype.hasOwnProperty('save')).to.be.true
     expect(CustomClass.prototype.hasOwnProperty('helloWorld')).to.be.true
     expect(CustomClass.hasOwnProperty('find')).to.be.true

    it 'should get the cached attributes name', ->
      object = new CustomClass()
      expect(object.cachedAttributes[0]).to.equal 'name'
      expect(object.cachedAttributes[1]).to.equal 'goal'

    it 'should saved the Object', (done) ->
      object = new CustomClass()
      object.save (err) ->
        throw err if err
        expect(object.id).to.not.equal undefined
        done()

    it 'should find a cached object inherited from CachedObject using its ID', (done) ->
      object = new CustomClass()
      object.save ->
        CustomClass.find object.id, (err, cachedObject) ->
          throw err if err
          expect(cachedObject.name).to.equal 'Hello'
          expect(cachedObject.goal).to.equal 'World'
          expect(cachedObject.foo).to.equal  'bar'
          done()

  describe 'Associations >', ->

    describe 'hasOne >', ->

      it 'should generate the setter and the getter', (done) ->
        object1 = new CustomClass()
        object2 = new AnotherClass()
        expect(object1.id).to.equal undefined
        expect(object2.id).to.equal undefined
        object2.setCustomClass object1, (object) ->
          expect(object2.customClass).to.not.equal undefined
          expect(object2.customClass.name).to.equal object1.name
          expect(object.name).to.equal object1.name
          object2.save ->
            expect(object1.id).to.not.equal undefined
            expect(object2.customClass.id).to.not.equal undefined
            expect(object2.id).to.not.equal undefined
            AnotherClass.find object2.id, (err, savedObject) ->
              expect(savedObject.customClass).to.equal undefined
              savedObject.getCustomClass (err, customObject) ->
                expect(customObject).to.not.equal undefined
                expect(savedObject.customClass.name).to.equal customObject.name
                expect(customObject.name).to.equal object1.name
                done()
