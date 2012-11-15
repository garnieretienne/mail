crypto  = require('crypto')
mimelib = require('mimelib')

class Message

  constructor: (attributes) ->
    @cachedAttributes = [ 'uid', 'seqno', 'json' ]
    if attributes
      @[key] = value for key, value of attributes
      @setDefaults()

  # Set default values
  setDefaults: ->
    @from.md5 = Message.generateMD5Hash(@from.address) if not @from.md5
    @sample = Message.generateSample(@body.text) if not @sample and @body

  json: ->
    object = 
      seqno: @seqno
      uid: @uid
      subject: @subject
      from: @from
      to: @to
      date: @date
      flags: @flags
    return JSON.stringify(object)

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

module.exports = Message