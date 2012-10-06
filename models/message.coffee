crypto = require('crypto')
riak = require('nodiak').getClient()

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

  # Get a message from Riak database
  @getByUID: (userId, uid, callback) ->
    userBucket = riak.bucket userId
    userBucket.objects.get uid, (err, obj) ->
      return callback err, new Message(obj.data)

  # Parse header 'to' field from a message parsed using 'mailparser'
  @parseHeaderFieldTo: (toField) ->
    toField.map (element, index, object) -> element.address

  # Generate a text sample from a text
  # Take the first 80 chars
  @generateSample: (text) ->
    if text.length > 50
      return text.substring(0, 50)+'...'
    else
      return text

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

  # Save a new message into Riak
  # Save to the good userid
  save: (userId, callback) ->
    userBucket = riak.bucket userId
    rObject = userBucket.object.new @uid, @
    userBucket.objects.save rObject, (err, obj) ->
      return callback(err) if callback

module.exports = Message