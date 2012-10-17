EventEmitter = require('events').EventEmitter
IMAP = require('../lib/imap')
Message = require './message'

# TODO: imap logout, = Account / disconnect
class Account

  # Password must be a private attribute
  password = ''

  # Connect to the imap server
  connect: (callback) ->
    _this = @
    imap = new IMAP 
      username: @username
      password: password
      host:     @imap.host
      port:     @imap.port
      secure:   @imap.secure
    @imap = imap
    @imap.on 'message:new', (message) ->
      _this.emit 'message:new', message
    @imap.connect (err) ->
      return callback(err) if err
      return callback(null)

  # Disconnect from the imap server
  disconnect: (callback) ->
    @imap.emit 'logout'
    return callback() if callback

  # Select a mailbox for futher actions
  # TODO: partial sync on select
  # TODO: events
  # TODO: mailbox object
  select: (mailbox, callback) ->
    _this = @
    @imap.open mailbox, (err, box) ->
      _this.mailbox = box # tmp
      return callback(err)

  # Synchronize the selected mailbox.
  # Type:
  #  - partial
  #  - full
  # Events: 
  #  - error: append when an error append on message fetch
  #  - end  : append when the synchronization is done
  # TODO: full, partial (new + old), new, old
  synchronize: (settings, callback) ->
    _this = @
    type       = settings.type || 'partial'
    maxSeqno   = @mailbox.messages.total
    processed  = 0
    fetchEvents = new EventEmitter()
    
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

    # Fetch and cache the headers using range
    # When a message is fetched, 
    # save it in the database and
    # emit a 'new message' event.
    @imap.on 'fetchHeaders:data', (imapMessage) ->
      Message.fromImapMessage imapMessage, (message) ->
        message.save _this.username, (err) ->
          fetchEvents.emit('error', err) if err
          _this.emit 'message:new', message
          processed = processed + 1
          if processed == maxSeqno
            fetchEvents.emit('end') 

    # Using nextTick to be able to listen for events.
    # http://howtonode.org/understanding-process-next-tick
    process.nextTick ->
     for range in ranges
        _this.imap.fetchHeaders range
    return fetchEvents

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