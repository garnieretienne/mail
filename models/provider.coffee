class Provider

  constructor: (attributes) ->
    @cachedAttributes = ['name', 'imapHost', 'imapPort', 'imapSecure', 'smtpHost', 'smtpPort', 'smtpSecure']
    @[key] = value for key, value of attributes

module.exports = Provider