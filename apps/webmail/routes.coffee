ImapConnection = require('imap').ImapConnection
MailParser = require("mailparser").MailParser

routes = (app) ->

    app.get '/', (req, res) ->
      
      # Imap settings
      imapSettings =
        username: 'webmail.testing.dev@gmail.com',
        password: 'imnotstrong',
        host: 'imap.gmail.com',
        port: 993,
        secure: true

      # Imap stack
      connect= ->
        imap = new ImapConnection(imapSettings)
        imap.connect (err) ->

          # Errors on connection
          if err
            console.log "IMAP: connection error: #{err}"
          else
            console.log "IMAP: connected to #{imapSettings.username}"

          # Close, End, Error
          imap.on 'close', (hadError) ->
            console.log "IMAP: connection closed (error?: #{hadError})."
          imap.on 'end', ->
            console.log "IMAP: connection ended."
          imap.on 'error', ->
            console.log "IMAP: error: #{error}."

          # List mailboxes
          #inbox = ''
          #imap.getBoxes (err, data) ->
          #  mailboxes = []
          #  for mailbox of data
          #    mailboxes.push mailbox
          #  inbox = mailboxes[0]
          #  console.log mailboxes.join(', ')

          # Open the main mailbox: Inbox
          # TODO: find the main mailbox name using flag
          inbox = "Inbox"
          imap.openBox inbox, false, (err, box) ->
            if err
              console.log "IMAP: error opening #{inbox}: #{err}"
            else
              console.log "IMAP: connected to #{inbox}"

            messagesNumber = box.messages.total
            console.log "IMAP: #{inbox} has #{messagesNumber} messages"

            # On new messages
            # TODO: support for many new messages (actually only the last message is fetched)
            imap.on 'mail', (number) ->
              console.log "IMAP: new message (#{number})"
              seqno = messagesNumber+number
              messagesNumber++
              console.log "IMAP: trying to fetch last message (seqno ##{seqno})..."
              fetch = imap.seq.fetch seqno,
                request:
                  body: 'full'
                  headers: false
              fetch.on "message", (message) ->
                mailparser = new MailParser()
                message.on "data", (data) ->
                  mailparser.write(data.toString())
                mailparser.on "end", (mail_object) ->
                  console.log '.'
                  console.log "MailParser: From Name:   ", mail_object.from[0].name
                  console.log "MailParser: From Address:", mail_object.from[0].address
                  console.log "IMAP:       Date:        ", message.date
                  console.log "MailParser: Subject:     ", mail_object.subject
                  console.log "MailParser: Body Sample: ", mail_object.text
                  console.log '.'
                message.on "end", ->
                  console.log "IMAP: message fetched with seqno ##{message.seqno}"
                  mailparser.end()



      connect()
      res.render "#{__dirname}/views/index",
        title: 'Mail'

    #app.get '/test/socket', (req, res) ->
    #  io.sockets.emit "testing", "Hello Socket!"
    #  res.send 200

module.exports = routes