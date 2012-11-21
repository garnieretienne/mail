IMAP         = require('../lib/imap')
EventEmitter = require("events").EventEmitter
async        = require("async")

class Account

  constructor: (attributes) ->
    @cachedAttributes = ['emailAddress']
    if attributes
      @username      = attributes.username
      @emailAddress  = attributes.emailAddress || attributes.username
      @password      = attributes.password

  getDomainName: ->
    domain = /^[\w\.]+@([\w\.]+)$/.exec(@emailAddress)[1]
    return domain

  # Authenticate the account
  authenticate: (callback) ->
    _this = @
    @getProvider (err, provider) ->
      return callback(err, null) if err
      imapSettings =
        server: provider.imapServer
        port:   provider.imapPort
        secure: provider.imapSecure
      IMAP.authenticate imapSettings, _this.username, _this.password, (err, authenticated) ->
        return callback(err, authenticated)

  # Connect to the imap server
  # Open INBOX on connection.
  # TODO: events
  connect: (callback) ->
    _this = @
    @getProvider (err, provider) ->
      return callback(err, null) if err
      return callback(new Error('No provider attached to this account')) if provider == null
      imapSettings =
        server:   provider.imapServer
        port:     provider.imapPort
        secure:   provider.imapSecure
        username: _this.username
        password: _this.password
      _this.imap = new IMAP imapSettings
      _this.imap.connect (err) ->
        return callback(err)
    
  # Disconnect from the imap server
  disconnect: (callback) ->
    if @imap
      @imap.emit 'logout', ->
        return callback() if callback

  # Select a mailbox for futher actions
  # TODO: partial sync on select
  # TODO: events
  select: (mailbox, callback) ->
    if !@imap 
      err = new Error 'Not connected to any IMAP server'
      return callback(err)
    _this = @
    @imap.open mailbox.name, (err, box) ->
      return callback(err) if err
      mailbox.messages.total  = box.messages.total
      mailbox.messages.unread = box.messages.unseen
      _this.selectedMailbox = mailbox
      return callback(null)

  # Synchronize the selected mailbox.
  # Type:
  #  - partial
  #  - full
  # Events: 
  #  - error: append when an error append on message fetch
  #  - end  : append when the synchronization is done
  # TODO: full, partial (new + old), new, old
  # TODO: save uidvalidity
  synchronize: (settings, callback) ->
    if !@selectedMailbox
      err = new Error 'No selected mailbox'
      return callback(err)

    _this = @

    type        = settings.type || 'partial'
    maxSeqno    = @selectedMailbox.messages.total
    processed   = 0
    fetchEvents = new EventEmitter()
     
    # Segment the fetch
    messagePerRange = 10
    rangeNumber     = Math.floor(maxSeqno / messagePerRange)
    ranges          = []
    index           = 1
    if maxSeqno > messagePerRange
      for i in [1..rangeNumber]
        ranges.push "#{index}:#{messagePerRange*i}"
        index = (messagePerRange*i) + 1
    ranges.unshift "#{index}:*"
  
    # Fetch and cache the headers using range
    # When a message is fetched, 
    # save it in the database and
    # emit a 'new message' event.
    @imap.on 'fetchHeaders:data', (imapMessage) ->
      Mailbox = _this.constructor.hasMany[0]
      Message = Mailbox.hasMany[0]
      Message.fromImapMessage imapMessage, (message) ->
        message.setMailbox _this.selectedMailbox, ->
          message.save (err) ->
            return callback(err) if err
            _this.emit 'message:new', message
            processed = processed + 1
            if processed == maxSeqno
              fetchEvents.emit('end') 
    
    # Using nextTick to be able to listen for events.
    # http://howtonode.org/understanding-process-next-tick
    #process.nextTick ->
    for range in ranges
      _this.imap.fetchHeaders range

    fetchEvents.on 'end', ->
      return callback(null)

  # List the mailboxes from the IMAP server
  getIMAPMailboxes: (callback) ->
    Mailbox = @constructor.hasMany[0]
    if !@imap 
      err = new Error 'Not connected to any IMAP server'
      return callback(err, null)
    @imap.getMailboxes (err, IMAPMailboxes) ->
      Mailbox.convertIMAPMailboxes IMAPMailboxes, (mailboxes) ->
        return callback(err, mailboxes)

  # Subscribe to mailboxes: save the mailboxes and synchronize them
  # Event methods:
  #  - 'mailbox:new'
  #  - 'error'
  subscribe: (mailboxes, callback) ->
    _this = @
    if !@imap
      err = new Error 'Not connected to any IMAP server'
      return callback(err)
    @setMailboxes mailboxes, ->
      _this.save (err) ->
        return callback(err) if err
        async.forEachSeries mailboxes
          , (mailbox, next) ->
            mailbox.save (err) ->
              _this.emit 'error', err if err
              _this.emit 'mailbox:new', mailbox
              next()
          , ->
            callback(null)

Account.prototype.__proto__ = EventEmitter.prototype
module.exports = Account