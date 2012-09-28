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
          _this.fetchSeqno imap, seqno

        return callback(null, imap)

  # Fetch messages using seqno.
  # Return a callback with an array of parsed messages.
  fetchSeqno: (imap, seqno, callback) ->
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
        _this.emit "message:new", parsedMessage
      message.on "end", ->
        mailparser.end()
    fetch.on "end", ->
      return callback() if callback

IMAP.prototype.__proto__ = EventEmitter.prototype;
module.exports = IMAP