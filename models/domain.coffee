# Sequelized Models
SequelizedModels = require(__dirname + '/sequelize/sequelizedModels')
SequelizedDomain = SequelizedModels.Domain

# Migration
SequelizedModels.migrate()

class Domain

  #Inherit from DomainSequelize model
  @prototype: SequelizedDomain.build()
  @find: (attributes, callback) ->
    _this = @
    SequelizedDomain.find(attributes).success (sequelizedDomain) ->
      if sequelizedDomain
        domain = SequelizedModels.convert(sequelizedDomain, Domain)
        return callback(domain)
      else return callback(null)
  @sync: (attributes) ->
    return SequelizedDomain.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes

module.exports = Domain