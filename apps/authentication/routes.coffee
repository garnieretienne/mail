Account = require '../../models/account'

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: "Mail - Login"

  app.post '/sessions', (req, res) ->

    # TODO: add flash message with the given error
    # TODO: protect password, no clear storage even in session ?
    account = new Account
      username: req.body.username
      password: req.body.password
    account.findProvider (found) ->
      if found
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