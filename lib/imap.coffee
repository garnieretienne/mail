EventEmitter = require('events').EventEmitter
ImapConnection = require('imap').ImapConnection
MailParser = require("mailparser").MailParser

# Manage IMAP stack for this application
#   imap = new IMAP();
#   imap.on('new:message', function(message){
#     // process...
#   });
#   imap.connect(imapSettings, function(err, imapConnection) {
#     if (err) {
#       throw(err);
#     }
#     imap.on('logout', function(){
#       imapConnection.logout();
#     });
#   });
#   
#   imap.emit('logout'); // When you're finished
class IMAP

  # Authenticate an user using his email address
  # TODO: Use provider class to get IMAP server configuration
  @authenticate: (emailAddress, password, callback) ->
    imapServer = 
      server: 'imap.gmail.com'
      port: 993
      tls: true
    imapSettings = 
      username: emailAddress
      password: password 
      host: imapServer.server
      port: imapServer.port
      secure: imapServer.tls
    imap = new ImapConnection imapSettings
    imap.connect (err) ->
      return callback(err, false) if err
      return callback(null, true)

  # Connect an account, open the INBOX mailbox and listen for events
  # Return a callback with err and ImapConnection
  connect: (imapSettings, callback) ->
    _this = @
    imap = new ImapConnection imapSettings
    imap.connect (err) ->
      return callback(err, null) if err

      # Open the 'INBOX' mailbox and listen for events
      # Events:
      #  - new messages
      #  - TODO: message deleted
      #  - TODO: message flag updated
      #  - TODO: server alert
      imap.openBox "INBOX", false, (err, box) ->
        return callback(err, imap) if err
        messagesNumber = box.messages.total

        # IMAP server event: new messages.
        # "Fires when new mail arrives in the currently open mailbox".
        imap.on 'mail', (number) ->
          if number == 1
            seqno = messagesNumber+number
          else
            seqno = "#{messagesNumber+1}:#{messagesNumber+number}"
          messagesNumber = messagesNumber + number
          _this.fetchNewMessage imap, seqno

        return callback(null, imap)

  # Fetch new messages using seqno.
  # Emit an event "message:new".
  fetchNewMessage: (imap, seqno, callback) ->
    _this = @
    fetch = imap.seq.fetch seqno,
      request:
        body: 'full'
        headers: false
    fetch.on "message", (message) ->
      mailparser = new MailParser()      
      message.on "data", (data) ->
        mailparser.write(data.toString())
      mailparser.on "end", (parsedMessage) ->
        imapFields = 
          seqno: message.seqno
          uid: message.uid
          date: message.date
          flags: _this.formatFlags(message.flags)
        _this.emit "message:new", parsedMessage, imapFields
      message.on "end", ->
        mailparser.end()
    fetch.on "end", ->
      return callback() if callback

  # Format flags name
  #   \\Seen => Seen
  formatFlags: (flags) ->
    flags.map (element, index, object) ->
      element.substring(1) if element[0] == "\\"

IMAP.prototype.__proto__ = EventEmitter.prototype;
module.exports = IMAP