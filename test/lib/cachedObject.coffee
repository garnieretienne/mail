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

class Mailbox

  constructor: (attributes) ->
    @cachedAttributes = ['name']
    @[key] = value for key, value of attributes

class Message

  constructor: (attributes) ->
    @cachedAttributes = ['subject', 'from']
    @[key] = value for key, value of attributes

Mailbox.hasMany = [Message]
Message.belongsTo = [Mailbox]

CachedObject.extends(Mailbox)
CachedObject.extends(Message)

# ---------------------------------------------------------

describe 'Cached Objects >', ->

  describe 'Pure Cached Object >', ->

    it 'should create a cached object', ->
      cachedObject = new CachedObject()

    it 'should save a non saved cachedObject', (done) ->
      cachedObject = new CachedObject()
      cachedObject.name = 'Cached Object'
      cachedObject.goal = 'Manage cache for object attributes'
      cachedObject.cachedAttributes = ['name', 'goal']
      expect(cachedObject.id).to.equal undefined
      cachedObject.save (err) ->
        throw err if err
        expect(cachedObject.id).to.not.equal undefined
        done()

    it 'should update an already saved cachedObject', (done) ->
      cachedObject = new CachedObject()
      cachedObject.name = 'Cached Object'
      cachedObject.goal = 'Manage cache for object attributes'
      cachedObject.cachedAttributes = ['name', 'goal']
      cachedObject.save (err) ->
        id = cachedObject.id
        cachedObject.name = 'New Name'
        cachedObject.save (err) ->
          throw err if err
          expect(cachedObject.id).to.equal id
          expect(cachedObject.name).to.equal 'New Name'
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

    it 'should find a cached object using any cached attribute', (done) ->
      object = new CachedObject()
      object.name = 'Amazing Cached Object'
      object.goal = 'Manage cache for object attributes'
      object.cachedAttributes = ['name', 'goal']
      object.save ->
        CachedObject.find {name: 'Amazing Cached Object', goal: 'Manage cache for object attributes'}, (err, cachedObjects) ->
          throw err if err
          expect(cachedObjects[0].name).to.equal object.name
          expect(cachedObjects[0].goal).to.equal object.goal
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

    it 'should update a saved object', (done) ->
      object = new CustomClass()
      object.save (err) ->
        throw err if err
        id = object.id
        object.name = 'World'
        object.save (err) ->
          throw err if err
          expect(object.id).to.equal id
          expect(object.name).to.equal 'World'
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

    describe 'belongsTo >', ->

      it 'should generate the setter and the getter', (done) ->
        mailbox = new Mailbox
          name: 'INBOX'
        message = new Message
          from:    'testing@domain.tld'
          subject: 'Hello Test !'
        message.setMailbox mailbox, (returnedMailbox) ->
          expect(message.mailbox).to.not.equal undefined
          expect(message.mailbox.name).to.equal mailbox.name
          expect(returnedMailbox.name).to.equal mailbox.name
          message.save ->
            expect(mailbox.id).to.not.equal undefined
            expect(message.id).to.not.equal undefined
            Message.find message.id, (err, returnedMessage) ->
              expect(returnedMessage).to.not.equal undefined
              expect(returnedMessage.mailbox).to.equal undefined
              returnedMessage.getMailbox (err, attachedMailbox) ->
                expect(attachedMailbox).to.not.equal undefined
                expect(returnedMessage.mailbox).to.not.equal undefined
                expect(returnedMessage.mailbox.name).to.equal mailbox.name
                done()

    describe 'hasMany >', ->

      it 'should generate the setter and the getter', (done) ->
        mailbox = new Mailbox
          name: 'INBOX'
        message1 = new Message
          from:    'testing@domain.tld'
          subject: 'Hello Test !'
        message2 = new Message
          from:    'admin@domain.tld'
          subject: 'Reseting your password'
        mailbox.setMessages [message1, message2], (messages) ->
          expect(messages[0].subject).to.equal message1.subject
          expect(messages[1].subject).to.equal message2.subject
          expect(message1.mailbox.name).to.equal mailbox.name
          expect(message2.mailbox.name).to.equal mailbox.name
          message1.getMailbox (err, attachedMailbox) ->
            expect(attachedMailbox.name).to.equal mailbox.name
            mailbox.save ->
              expect(mailbox.id).to.not.equal undefined
              expect(message1.id).to.equal undefined
              expect(message2.id).to.equal undefined
              message1.save ->
                message2.save ->
                  expect(message1.id).to.not.equal undefined
                  expect(message2.id).to.not.equal undefined
                  Mailbox.find mailbox.id, (err, returnedMailbox) ->
                    expect(returnedMailbox).to.not.equal undefined
                    returnedMailbox.getMessages (err, attachedMessages) ->
                      expect(attachedMessages[0].subject).to.equal 'Hello Test !'
                      expect(attachedMessages[1].subject).to.equal 'Reseting your password'
                      done()
