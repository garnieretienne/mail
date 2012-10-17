EventEmitter = require('events').EventEmitter
IMAP = require('../lib/imap')
Message = require './message'
Mailbox = require './mailbox'
Provider = require './provider'

# TODO: imap logout, = Account / disconnect
class Account

  # Password must be a private attribute
  password = ''

  constructor: (attributes) ->
    @username = attributes.username
    password = attributes.password

  # Connect to the imap server
  connect: (callback) ->
    if !@imap || !@smtp
      return callback(new Error('No provider set!'))
    _this = @
    @imap = new IMAP 
      username: @username
      password: password
      host:     @imap.host
      port:     @imap.port
      secure:   @imap.secure
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
      _this.mailbox = new Mailbox
        name:        box.name
        uidvalidity: box.uidvalidity
        messages:
          total:     box.messages.total
          unread:    box.messages.unseen
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

  # Find the email address provider
  findProvider: (callback) ->
    _this = @
    Provider.search @username, (err, provider) ->
      if provider.name
        _this.imap = provider.imap
        _this.smtp = provider.smtp
        return callback(true)
      return callback(false)

Account.prototype.__proto__ = EventEmitter.prototype;
module.exports = Account