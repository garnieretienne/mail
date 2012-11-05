sequelize = require(__dirname+'/../config/database')
TestObjectSequelize = sequelize.import(__dirname + "/testSequelize")
TestObjectSequelize.sync()

class TestObject
  @prototype: TestObjectSequelize.build()

  constructor: ->
    @foo = 'bar'

  instanceMethod: ->
    return null

  @classMethod: ->
    return null

  @helloYou: ->
    return "Hello You"

  helloWorld: ->
    return "Hello World"

# Extend from TestObjectSequelize (ORM Sequelize Object)
#TestObject.prototype = TestObjectSequelize.build()

# Class method
#TestObject.helloYou = ->
#  return "Hello You"

# Instance method
#TestObject.prototype.helloWorld = ->
#  return "Hello World"

module.exports = TestObject