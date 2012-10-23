Account = require '../../models/account'

routes = (app) ->

  # Authentication
  app.all '/mail', (req, res, next) ->
    if not req.session.currentUser
      res.redirect '/login'
      return
    next()

  app.get '/', (req, res) ->
    res.redirect 'mail'

  app.get '/mail', (req, res) ->

    # Create the account with user validated credentials
    account = new Account
      username: req.session.currentUser
      password: req.session.password

    # Events
    account.on 'message:new', (message) ->
      io.sockets.emit "message:new", message

    # Get the account provider informations
    account.findProvider ->

      # Connect to the IMAP server
      account.connect (err) ->
        throw err if err

        # Open the INBOX
        account.select 'INBOX', (err, mailbox) ->
          throw err if err

          # Synchronize the INBOX
          sync = account.synchronize
            type: 'full'
          sync.on 'error', (err) ->
            throw err if err

    res.render "#{__dirname}/views/index",
      title: 'Mail'
      user: req.session.currentUser

module.exports = routes