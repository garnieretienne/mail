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
        io.sockets.emit "message:new", message
      me.connect (err) ->
        console.log err if err

      res.render "#{__dirname}/views/index",
        title: 'Mail'

module.exports = routes