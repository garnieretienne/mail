EventEmitter = require('events').EventEmitter
IMAP = require('../lib/imap')
Message = require './message'

class Account

  # Password must be a private attribute
  password = ''

  # Connect to the imap server and open the 'INBOX' mailbox
  # Events for:
  #  - new message (message:new)
  #  - TODO: message deleted
  #  - TODO: message flag updated
  #  - TODO: server alert
  # TODO: manage disconnect using event
  connect: (callback) ->
    _this = @
    imapSettings =
      username: @username
      password: password
      host:     @imap.host
      port:     @imap.port
      secure:   @imap.secure
    imap = new IMAP()
    imap.on 'message:new', (message) ->
      _this.emit 'message:new', message
    imap.connect imapSettings, (err, imapConnection) ->
      return callback(err) if err
      return callback(null)

  # Authenticate the account
  authenticate: (callback) ->
    IMAP.authenticate @imap, @username, password, (err, authenticated) ->
      return callback(err, authenticated)

  constructor: (attributes) ->
    @username = attributes.username
    password = attributes.password
    @setProvider()

  # Find the address provider
  # TODO: use the Provider model, for now set with GMAIL parameters
  setProvider: ->
    @imap = 
      host:   'localhost'
      port:   '993'
      secure: true

Account.prototype.__proto__ = EventEmitter.prototype;
module.exports = Account