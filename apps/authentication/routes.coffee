Models   = require(__dirname+'/../../models/models')
Account  = Models.Account
Domain   = Models.Domain
Provider = Models.Provider
Mailbox  = Models.Mailbox

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: "Mail - Login"

  app.post '/sessions', (req, res) ->

    # TODO: add flash message with the given error
    # TODO: protect password, no clear storage even in session ?
    # TODO: search in database if account already exist
    account = new Account
      username: req.body.username
      password: req.body.password
    domainName = account.getDomainName()
    Domain.find {name: domainName}, (err, results) ->
      throw err if err
      if results[0]
        domain = results[0]
        domain.getProvider (err, provider) ->
          throw err if err
          account.setProvider provider, ->
            account.authenticate (err, authenticated) ->
              if authenticated
                req.session.currentUser = account.username
                req.session.password    = req.body.password
                res.redirect '/mail'
                return
              res.redirect '/login'
              return
      else
        res.redirect '/login'

  # TODO: add flash message with the given error
  # TODO: end any socket connection and IMAP connections
  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      res.send 200

module.exports = routes