class Domain

  constructor: (attributes) ->
    @cachedAttributes = ['name']
    @[key] = value for key, value of attributes

module.exports = Domain