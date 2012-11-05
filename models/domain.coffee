# Sequelized Models
SequelizedModels = require(__dirname + '/sequelize/sequelizedModels')
SequelizedDomain = SequelizedModels.Domain

class Domain

  # Inherit from DomainSequelize model
  @prototype: SequelizedDomain.build()
  @find: (attributes) ->
    return SequelizedDomain.find attributes
  @sync: (attributes) ->
    return SequelizedDomain.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes

module.exports = Domain