IMAP = require '../../lib/imap'

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: "Mail - Login"

  app.post '/sessions', (req, res) ->
    username = req.body.username
    password = req.body.password

    # TODO: add flash message with the given error
    IMAP.authenticate username, password, (err, authenticated) ->
      if authenticated
        req.session.currentUser = username
        res.redirect '/mail'
        return
      #console.log err
      res.redirect '/login'

  # TODO: add flash message with the given error
  # TODO: end any socket connection and IMAP connections
  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      res.redirect '/login'

module.exports = routes