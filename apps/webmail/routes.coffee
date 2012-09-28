ImapConnection = require('imap').ImapConnection
MailParser = require("mailparser").MailParser
Account = require '../../models/account'

routes = (app) ->

    app.get '/', (req, res) ->

      # Connect to a test account and display any new message's 
      # subject in the server console
      tmpAxx = 
        username: 'webmail.testing.dev@gmail.com',
        password: 'imnotstrong'
      me = new Account tmpAxx
      me.on 'message:new', (message) ->
        console.log message.subject
      me.connect (err) ->
        console.log err if err

      res.render "#{__dirname}/views/index",
        title: 'Mail'

    # Testing Socket
    #app.get '/test/socket', (req, res) ->
    #  io.sockets.emit "testing", "Hello Socket!"
    #  res.send 200

module.exports = routes