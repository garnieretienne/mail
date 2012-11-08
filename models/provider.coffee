# Sequelized Models
SequelizedModels   = require(__dirname + '/sequelize/sequelizedModels')
SequelizedProvider = SequelizedModels.Provider

# Models
Domain = require(__dirname + '/domain')

class Provider
  @prototype: SequelizedProvider.build()
  @find: (attributes, callback) ->
    _this = @
    SequelizedProvider.find(attributes).success (sequelizedProvider) ->
      if sequelizedProvider
        provider = SequelizedModels.convert(sequelizedProvider, Provider)
        return callback(provider)
      else return callback(null)
  @sync: (attributes) ->
    return SequelizedProvider.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes

  @search: (emailAddress, callback) ->
    domain = /^[\w\.]+@([\w\.]+)$/.exec(emailAddress)[1]
    Domain.find where: {name: domain}, (domain) ->
      if domain
        domain.getProvider().success (sequelizedProvider) ->
          provider = SequelizedModels.convert(sequelizedProvider, Provider)
          return callback(provider)
      else
        return callback(null)

module.exports = Provider