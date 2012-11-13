CachedObject = require(__dirname+'/../lib/cachedObject')
Domain       = require(__dirname+'/domain')
Provider     = require(__dirname+'/provider')

class Models

  constructor: ->

    # Setup association beetween models
    Domain.belongsTo = [ Provider ]
    Provider.hasMany = [ Domain ]

    # Extends models with DAO methods
    CachedObject.extends Domain
    CachedObject.extends Provider

    @Domain   = Domain
    @Provider = Provider

module.exports = new Models()