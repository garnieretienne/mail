# Sequelized Models
SequelizedModels   = require(__dirname + '/sequelize/sequelizedModels')
SequelizedProvider = SequelizedModels.Provider

# Models
Domain = require(__dirname+'/domain')

class Provider
  @prototype: SequelizedProvider.build()
  @find: (attributes) ->
    return SequelizedProvider.find attributes
  @sync: (attributes) ->
    return SequelizedProvider.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes

  @search: (emailAddress, callback) ->
    domain = /^[\w\.]+@([\w\.]+)$/.exec(emailAddress)[1]
    Domain.find({name: domain}).success (domain) ->
      if domain
        domain.getProvider().success (provider) ->
          return callback(provider)
      else
        return callback(null)

module.exports = Provider