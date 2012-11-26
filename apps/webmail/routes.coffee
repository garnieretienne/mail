Models   = require(__dirname+'/../../models/models')
Account  = Models.Account
Domain   = Models.Domain
Provider = Models.Provider
Mailbox  = Models.Mailbox

routes = (app, io) ->

  # Authentication
  app.all '/mail', (req, res, next) ->
    if not req.session.currentUser
      res.redirect '/login'
      return
    next()

  app.get '/', (req, res) ->
    res.redirect 'mail'

  app.get '/mail', (req, res) ->

    res.render "#{__dirname}/views/index",
      title: 'Mail'
      user: req.session.currentUser
    , (err, html) ->
      throw err if err
      res.send html

      connections = []
      io.sockets.on 'connection', (socket) ->

        # Temporary fix a bug with deplicated events
        # https://github.com/LearnBoost/socket.io/issues/430
        connections.push socket.id
        if connections.length > 1
          return

        getInbox = (account, callback) ->
          Mailbox.find {where: {name: 'INBOX', account_id: account.id}, limit: 1}, (err, mailbox) ->
            throw err if err
            mailbox = mailbox[0]
            if !mailbox
              err = new Error 'No INBOX subscribed'
              return callback(err, null)
            else
              return callback(null, mailbox)

        getMailboxes = (account, callback) ->
          account.getMailboxes (err, mailboxes) ->
            throw err if err
            
            # If no mailboxes had been subscribed yet, 
            # display the mailbox subscriber screen.
            if mailboxes.length == 0
              account.getIMAPMailboxes (err, mailboxes) ->
                throw err if err

                # Subscribe to all account mailbox.
                # TODO: let user decide which mailboxes he wants to subscribe.
                account.subscribe mailboxes, (err) ->
                  throw err if err

                  return callback(mailboxes)
            else
              return callback(mailboxes)

        Account.find req.session.currentUserId, (err, account) ->
          throw err if err
          account.username = req.session.currentUser
          account.password = req.session.password

          # Events
          # ------
          # When a new mailbox is subscribed, 
          # tell it to backbone.
          account.on 'mailbox:new', (mailbox) ->
            socket.emit "mailbox:new", mailbox
          # When a new message is discovered,
          # tell it to backbone.
          account.on 'message:new', (message) ->
            socket.emit "message:new", message

          account.connect (err) ->
            throw err if err

            # Disconnect the IMAP connection when the WebSocket connection is disconnected
            socket.on 'disconnect', ->
              account.disconnect()

            getMailboxes account, (mailboxes) ->
              
              getInbox account, (err, inbox) ->
                throw err if err

                account.select inbox, (err) ->
                  throw err if err

                  # Get cached messages and render the UI
                  inbox.getMessages (err, messages) ->
                    throw err if err
                    
                    # Synchronization
                    if inbox.uidValidity != inbox.serverUidValidity
                        account.synchronize {type: 'full'}, (err) ->
                          throw err if err
                          inbox.uidValidity = inbox.serverUidValidity
                          inbox.save (err) ->
                            throw err if err
                    else
                      # TODO: partial sync
                      # account.synchronize {type: 'partial'}, (err) ->
                      #   throw err if err
                      #   socket.emit "message:all", messages
                      socket.emit "message:all", messages
                      socket.emit "mailbox:all", mailboxes


module.exports = routes