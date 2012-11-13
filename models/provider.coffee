class Provider

  constructor: (attributes) ->
    @cachedAttributes = ['name', 'imap_host', 'imap_port', 'imap_secure', 'smtp_host', 'smtp_port', 'smtp_secure']
    @[key] = value for key, value of attributes

  # @search: (emailAddress, callback) ->
  #   domain = /^[\w\.]+@([\w\.]+)$/.exec(emailAddress)[1]
  #   Domain.find where: {name: domain}, (domain) ->
  #     if domain
  #       domain.getProvider().success (sequelizedProvider) ->
  #         provider = SequelizedModels.convert(sequelizedProvider, Provider)
  #         return callback(provider)
  #     else
  #       return callback(null)

module.exports = Provider