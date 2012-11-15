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

    # Create the account with user validated credentials
    # TODO: load it from the database
    account = new Account
      username: req.session.currentUser
      password: req.session.password

    # Events
    account.on 'message:new', (message) ->
      io.sockets.emit "message:new", message

    # Get the account provider informations
    domainName = account.getDomainName()
    Domain.find {name: domainName}, (err, results) ->
      throw err if err
      if results[0]
        domain = results[0]
        domain.getProvider (err, provider) ->
          throw err if err
          account.setProvider provider, ->

            # Connect to the IMAP server
            account.connect (err) ->
              throw err if err

              account.getIMAPMailboxes (err, IMAPMailboxes) ->
                Mailbox.convertIMAPMailboxes IMAPMailboxes, (mailboxes) ->
                  inbox
                  for mailbox in mailboxes
                    inbox  = mailbox if mailbox.name = 'INBOX'

                  # Open the INBOX
                  account.select inbox, (err, mailbox) ->
                    throw err if err

                    # Synchronize the INBOX
                    account.synchronize {type: 'full'}, (err) ->
                      throw err if err

    res.render "#{__dirname}/views/index",
      title: 'Mail'
      user: req.session.currentUser

module.exports = routes