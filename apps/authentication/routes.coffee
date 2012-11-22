Models   = require(__dirname+'/../../models/models')
Account  = Models.Account
Domain   = Models.Domain
Provider = Models.Provider
Mailbox  = Models.Mailbox

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: "Mail - Login"

  # TODO: add flash message with the given error
  app.post '/sessions', (req, res) ->

    # Try to authenticate the user
    authentication = (account, callback) ->
      account.authenticate (err, authenticated) ->
        if authenticated
          req.session.currentUserId = account.id
          req.session.currentUser   = account.username
          req.session.password      = req.body.password
          return callback(null)
        else
          return callback(err)

    # Find the account.
    # Load the account from the database if its already registered.
    # Create a new one if not registered.
    # Return an error if no provider are found for this email.
    getAccount = (callback) ->
      Account.find {where: {emailAddress: req.body.username}, limit: 1}, (err, account) -> 
        return callback(err, null) if err

        # Existing user
        if account[0]
          account = account[0]
          account.username = req.body.username
          account.password = req.body.password  
          return callback(null, account)

        # New user
        else
          account = new Account
            username: req.body.username
            password: req.body.password
          domainName = account.getDomainName()
          Domain.find {where: {name: domainName}, limit: 1}, (err, domain) ->
            throw err if err

            # Provider found
            if domain[0]
              domain = domain[0]
              domain.getProvider (err, provider) ->
                throw err if err
                account.setProvider provider, ->
                  return callback(null, account)

            # No provider found
            else
              err = new Error 'No provider found for this email address'
              return callback(err, account)

    # Get the account details and try to authenticate.
    # If the authentication is successfull, register the account.
    getAccount (err, account) ->
      if err
        res.redirect '/login'
        return
      authentication account, (err) ->
        if err
          res.redirect '/login'
          return
        if !account.id
          account.save (err) ->
            throw err if err
            # TODO: replace the following by displaying the subscribe mailbox chooser
            # -----------------------------------------------------------------------
            mailbox = new Mailbox
              name: 'INBOX'
            mailbox.setAccount account, ->
              mailbox.save (err) ->
                throw err if err
                res.redirect '/mail'
                return
            # -----------------------------------------------------------------------
        else
          res.redirect '/mail'
          return

  # TODO: add flash message with the given error
  # TODO: end any socket connection and IMAP connections
  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      res.send 200

module.exports = routes