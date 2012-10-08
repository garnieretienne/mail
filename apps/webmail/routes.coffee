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

    # Connect to a test account and display any new message's 
    # subject in the server console
    me = new Account
      username: req.session.currentUser
      password: req.session.password
    me.on 'message:new', (message) ->
      io.sockets.emit "message:new", message
      message.save req.session.currentUser, (err) ->
        #console.log "#{err}" if err
    me.connect (err) ->
      #console.log "Account.connect: #{err}" if err

    res.render "#{__dirname}/views/index",
      title: 'Mail'
      user: req.session.currentUser

module.exports = routes