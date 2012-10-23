crypto = require('crypto')
riak = require('nodiak').getClient()
mimelib = require('mimelib')


class Message

  constructor: (attributes) ->
    @[key] = value for key, value of attributes
    @setDefaults()

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
      subject: mimelib.parseMimeWords(parsedMessage.subject),
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
      subject: mimelib.parseMimeWords(imapMessage.headers.subject[0]),
      from:
        name: Message.parseImapMessageHeaderFieldFrom(imapMessage.headers.from[0], 'name'),
        address: Message.parseImapMessageHeaderFieldFrom(imapMessage.headers.from[0], 'address'),
      to: imapMessage.headers.to,
      date: imapMessage.date,
      flags: imapMessage.flags
      parts: Message.mapPartIDs(imapMessage.structure)
    callback(message)

  # Get a message from Riak database using the UID
  @getByUID: (userId, mailboxName, uid, callback) ->
    userBucket = riak.bucket "#{userId}:#{mailboxName}"
    userBucket.objects.get uid, (err, obj) ->
      return callback err, new Message(obj.data)

  # Get a message from the Riak database usng the sequence number
  @getBySeqno: (userId, mailboxName, seqno, callback) ->
    userBucket = riak.bucket "#{userId}:#{mailboxName}"
    keys = []
    userBucket.search.twoi seqno, 'seqno', (err, key) ->
      return callback(err, null) if err or key.length == 0
      Message.getByUID userId, mailboxName, key, (err, message) ->
        return callback(err, message)

  # Get all messages for the given user in the given mailbox
  @all: (userId, mailboxName, callback) ->
    userBucket = riak.bucket "#{userId}:#{mailboxName}"

  # Parse header field 'to' from a message parsed using 'mailparser'
  @parseMailParserHeaderFieldTo: (toField) ->
    toField.map (element, index, object) -> element.address

  # Parse header field 'from' from an ImapMessage field
  # TODO: better support for 
  #  - "MR TOTO <toto@toto.com>"
  #  - "toto@toto.com"
  @parseImapMessageHeaderFieldFrom: (fromField, element) ->
    if element == 'name'
      matchResult = fromField.match(/(.*) </)
      return mimelib.parseMimeWords(matchResult[1]) if matchResult 
    if element == 'address'
      matchResult = fromField.match(/<(.*)>/)
      if matchResult
        return mimelib.parseMimeWords(matchResult[1])
      else return fromField
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

  # Set default values
  setDefaults: ->
    @from.md5 = Message.generateMD5Hash(@from.address) if not @from.md5
    @sample = Message.generateSample(@body.text) if not @sample and @body

  # Save a new message into Riak
  save: (userId, mailboxName, callback) ->
    userBucket = riak.bucket "#{userId}:#{mailboxName}"
    rObject = userBucket.object.new @uid, @
    rObject.addToIndex 'seqno', @seqno
    userBucket.objects.save rObject, (err, obj) ->
      return callback(err) if callback

module.exports = Message