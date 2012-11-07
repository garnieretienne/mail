IMAP = require('../lib/imap')

# Sequelized Models
SequelizedModels   = require(__dirname + '/sequelize/sequelizedModels')
SequelizedAccount  = SequelizedModels.Account

# Models
Provider = require(__dirname + '/provider')
Mailbox  = require(__dirname + '/mailbox')
Message  = require(__dirname + '/message')

class Account
  @prototype = SequelizedAccount.build()
  @find: (attributes, callback) ->
    _this = @
    SequelizedAccount.find(attributes).success (sequelizedAccount) ->
      if sequelizedAccount
        #Account.prototype.__proto__ = sequelizedAccount
        account = new Account()
        return callback(account)
      else return callback(null)
  @sync: (attributes) ->
    return SequelizedAccount.sync attributes

  constructor: (attributes) ->
    if attributes
      @username      = attributes.username
      @emailAddress  = attributes.emailAddress || attributes.username
      @password      = attributes.password

  # Connect to the imap server
  # Open INBOX on connection.
  # TODO: events
  connect: (callback) ->
    _this = @
    @imapSettings (imapSettings) ->
      if imapSettings
        imapSettings.username = _this.username
        imapSettings.password = _this.password
        _this.imap = new IMAP imapSettings
        _this.imap.connect (err) ->
          return callback(err) if err

          # Cache the account if not cached
          # + Set up the provider association
          if _this.isNewRecord
            if !_this.ProviderId
              err = new Error 'this account cannot be cached without provider'
              return callback(err)
            _this.save().success ->
              _this.select 'INBOX', (err) ->
                return callback(err)
          else
            _this.select 'INBOX', (err) ->
                return callback(err)
      else
        err = new Error 'No imap settings for this email address'
        return callback(err)
    
  # Disconnect from the imap server
  disconnect: (callback) ->
    if @imap
      @imap.emit 'logout', ->
        return callback() if callback

  # Select a mailbox for futher actions
  # TODO: partial sync on select
  # TODO: events
  select: (mailboxName, callback) ->
    if !@imap 
      err = new Error 'Not connected to any IMAP server'
      return callback(err)
    _this = @
    @imap.open mailboxName, (err, box) ->
      _this.selectedMailbox = new Mailbox
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
    if !@selectedMailbox
      err = new Error 'No selected mailbox'
      return callback(err)
    
    #    _this = @
    #    type       = settings.type || 'partial'
    #    maxSeqno   = @mailbox.messages.total
    #    processed  = 0
    #    fetchEvents = new EventEmitter()
    #    
    #    # Segment the fetch
    #    messagePerRange = 10
    #    rangeNumber     = Math.floor(maxSeqno / messagePerRange)
    #    ranges = []
    #    index = 1
    #    if maxSeqno > messagePerRange
    #      for i in [1..rangeNumber]
    #        ranges.push "#{index}:#{messagePerRange*i}"
    #        index = (messagePerRange*i) + 1
    #    ranges.push "#{index}:*"
    #
    #    # Fetch and cache the headers using range
    #    # When a message is fetched, 
    #    # save it in the database and
    #    # emit a 'new message' event.
    #    @imap.on 'fetchHeaders:data', (imapMessage) ->
    #      Message.fromImapMessage imapMessage, (message) ->
    #        message.save _this.username, _this.mailbox.name, (err) ->
    #          fetchEvents.emit('error', err) if err
    #          _this.emit 'message:new', message
    #          processed = processed + 1
    #          if processed == maxSeqno
    #            fetchEvents.emit('end') 
    #
    #    # Using nextTick to be able to listen for events.
    #    # http://howtonode.org/understanding-process-next-tick
    #    process.nextTick ->
    #     for range in ranges
    #        _this.imap.fetchHeaders range
    #    return fetchEvents

  # Authenticate the account
  authenticate: (callback) ->
    _this = @
    @imapSettings (imapSettings) ->
      IMAP.authenticate imapSettings, _this.username, _this.password, (err, authenticated) ->
        return callback(err, authenticated)

  # Find the email address provider
  findProvider: (callback) ->
    Provider.search @emailAddress, (provider) ->
      if provider
        return callback(true, provider)
      else
        return callback(false, null)

  # Access IMAP settings
  # If account is not yet verified and saved into the database, use local variable to store imap settings,
  # Else return associed provider imap settings.
  imapSettings: (callback) ->
    _this = @
    @getProvider().success (provider) ->
      if provider
        # Provider is loaded from cache
        imap =
          server: provider.imap_server
          port:   provider.imap_port
          secure: provider.imap_secure
        return callback(imap)
      else
        _this.findProvider (found, provider) ->
          if found
            _this.ProviderId = provider.id # Cache the provider
            imap =
              server: provider.imap_host
              port:   provider.imap_port
              secure: provider.imap_secure
            return callback(imap)
          else
            return callback(null)

module.exports = Account