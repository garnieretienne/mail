crypto = require('crypto')
riak = require('nodiak').getClient()
IMAP = require '../lib/imap'

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
      to: Message.parseMailParserHeaderFieldTo(parsedMessage.to),
      date: imapFields.date,
      sample: Message.generateSample(parsedMessage.text),
      body:
        text: parsedMessage.text,
        html: parsedMessage.html
      flags: imapFields.flags
    callback(message)

  # Create a new message from an ImapMessage object (node-imap)
  @fromImapMessage: (imapMessage, callback) ->
    message = new Message
      seqno: imapMessage.seqno
      uid: imapMessage.uid,
      subject: imapMessage.headers.subject[0],
      from:
        name: Message.parseImapMessageHeaderFieldFrom(imapMessage.headers.from[0], 'name'),
        address: Message.parseImapMessageHeaderFieldFrom(imapMessage.headers.from[0], 'address'),
      to: imapMessage.headers.to,
      date: imapMessage.date,
      flags: IMAP.formatFlags(imapMessage.flags)
      parts: Message.mapPartIDs(imapMessage.structure)
    callback(message)

  # Get a message from Riak database
  @getByUID: (userId, uid, callback) ->
    userBucket = riak.bucket userId
    userBucket.objects.get uid, (err, obj) ->
      return callback err, new Message(obj.data)

  # Parse header field 'to' from a message parsed using 'mailparser'
  @parseMailParserHeaderFieldTo: (toField) ->
    toField.map (element, index, object) -> element.address

  # Parse header field 'from' from an ImapMessage field
  @parseImapMessageHeaderFieldFrom: (fromField, element) ->
    if element == 'name'
      return fromField.match(/"(.*)"/)[1]
    if element == 'address'
      return fromField.match(/<(.*)>/)[1]
    return ''

  # Analyze message structure returned by node-imap to find the 'text' type content.
  # Only multipart 'mixed' and 'alternative' multipart are browsed to ensure to get 
  # only one content of type 'text/html' or 'text/plain'.
  # Only 'text' type parts are mapped.  
  @mapPartIDs: (structure) ->
    structureParts = {}
    analyze = (structure) ->
      if structure.length > 1
        if ['mixed', 'alternative', 'text'].indexOf(structure[0].type) > -1
          subStructureNum = structure.length - 1
          for i in [1..subStructureNum]
            analyze structure[i] 
      else
        if ['text'].indexOf(structure[0].type) > -1
          structureParts["#{structure[0].type}/#{structure[0].subtype}"] = structure[0].partID
    analyze structure
    return structureParts

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
    @sample = Message.generateSample(@body.text) if not @sample and @body

  # Save a new message into Riak
  # Save to the good userid
  save: (userId, callback) ->
    userBucket = riak.bucket userId
    rObject = userBucket.object.new @uid, @
    userBucket.objects.save rObject, (err, obj) ->
      return callback(err) if callback

module.exports = Message