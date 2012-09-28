IMAP = require('../lib/imap')
EventEmitter = require('events').EventEmitter

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
      host:     @imap.server
      port:     @imap.port
      secure:   @imap.tls
    imap = new IMAP()
    imap.on 'message:new', (message) ->
      # TODO: build a Message class and convert message to a Message Object
      _this.emit 'message:new', message
    imap.connect imapSettings, (err, imapConnection) ->
      return callback(err) if err
      return callback(null)

  constructor: (attributes) ->
    @username = attributes.username
    password = attributes.password
    @setProvider()

  # Find the address provider
  # TODO: use the Provider model, for now set with GMAIL parameters
  setProvider: ->
    @imap = 
      server: 'imap.gmail.com'
      port:   '993'
      tls:    true

Account.prototype.__proto__ = EventEmitter.prototype;
module.exports = Account