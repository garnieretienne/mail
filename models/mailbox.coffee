class Mailbox

  constructor: (attributes) ->
    @cachedAttributes = ['name', 'selectable', 'uidValidity']
    @[key] = value for key, value of attributes
    @setDefaults()

  setDefaults: ->
    @selectable = true if @selectable == (null || undefined)
    @total = 0 if !@total
    @unread = 0 if !@unread

  # Convert a mailbox object into JSON without circular references
  toJSON: ->
    return @toJSONQuery(['id', 'name', 'selectable', 'total', 'unread', 'mailboxId'])

  # Convert an array of node-imap mailboxes to Mailbox models.
  # mailbox.attribs can be null on some IMAP server (dovecot) on non-selectable folder.
  @convertIMAPMailboxes: (IMAPMailboxes, callback) ->
    mailboxes = []
    for key of IMAPMailboxes
      mailbox = new Mailbox
        name: key
        selectable: if IMAPMailboxes[key].hasOwnProperty('attribs') then !('NOSELECT' in IMAPMailboxes[key].attribs) else false
      mailboxes.push mailbox
      if IMAPMailboxes[key].children
        for subkey of IMAPMailboxes[key].children
          childMailbox = new Mailbox
            name: subkey
            selectable: if IMAPMailboxes[key].children[subkey].hasOwnProperty('attribs') then !('NOSELECT' in IMAPMailboxes[key].children[subkey].attribs) else false
          childMailbox.setMailbox mailbox, ->
            mailboxes.push childMailbox
    return callback(mailboxes)

module.exports = Mailbox