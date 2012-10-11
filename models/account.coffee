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
    imap.connect imapSettings, (err, imapConnection, box) ->
      return callback(err, null, null) if err
      return callback(null, imap, imapConnection, box)

  # TODO: chose mailbox. For now, mailbox is given by the box object
  synchronize: (imap, imapConnection, box, settings, callback) ->
    _this = @

    mailbox         = settings.mailbox || 'INBOX' # unused
    type            = settings.type || 'partial'
    maxSeqno        = box.messages.total
    
    # Segment the fetch
    messagePerRange = 10
    rangeNumber     = Math.floor(maxSeqno / messagePerRange)
    ranges = []
    index = 1
    if maxSeqno > messagePerRange
      for i in [1..rangeNumber]
        ranges.push "#{index}:#{messagePerRange*i}"
        index = (messagePerRange*i) + 1
    ranges.push "#{index}:*"

    # Fetch and cache the headers
    # TODO: better asynchronous iteration patterns
    imap.on 'fetchHeaders:data', (message) ->
      message.save _this.username, (err) ->
        _this.emit 'message:new', message if !err
    for range in ranges
      imap.fetchHeaders imapConnection, range, ->
        # Return callback only after the last range
        return callback() if callback && range == ranges[ranges.length-1] 
    

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