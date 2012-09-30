crypto = require('crypto')

class Message

  # Create a new Message object from a MailParser Object and an imapFields hash
  # ImapFields must contain:
  #  - uid
  #  - seqno
  #  - flags
  #  - date (when the message was received)
  # TODO: manage errors
  @fromMailParser: (parsedMessage, imapFields, callback) ->
    message = new Message
      seqno: imapFields.seqno,
      uid: imapFields.uid,
      subject: parsedMessage.subject,
      from:
        name: parsedMessage.from[0].name,
        address: parsedMessage.from[0].address,
        md5: Message.generateMD5Hash parsedMessage.from[0].address
      to: Message.parseHeaderFieldTo(parsedMessage.to),
      date: imapFields.date,
      sample: Message.generateSample(parsedMessage.text),
      body:
        text: parsedMessage.text,
        html: parsedMessage.html
      flags: imapFields.flags
    callback(message)

  # Parse header 'to' field from a message parsed using 'mailparser'
  @parseHeaderFieldTo: (toField) ->
    toField.map (element, index, object) -> element.address

  # Generate a text sample from a text
  # Take the first 80 chars
  @generateSample: (text) ->
    text.substring(0, 50)+'...'

  # Generate a md5 hash from an email address
  @generateMD5Hash: (email) ->
    crypto.createHash('md5').update(email).digest('hex')

  constructor: (attributes) ->
    @[key] = value for key, value of attributes
    @setDefaults()

  # Set default values
  setDefaults: ->
    @from.md5 = Message.generateMD5Hash(@from.address) if not @from.md5
    @sample = Message.generateSample(@body.text) if not @sample

module.exports = Message