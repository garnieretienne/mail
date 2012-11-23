class Mailbox

  constructor: (attributes) ->
    @cachedAttributes = ['name', 'selectable', 'uidValidity']
    @[key] = value for key, value of attributes
    @setDefaults()

  setDefaults: ->
    @selectable = true if @selectable == (null || undefined)
    @total = 0 if !@total
    @unread = 0 if !@unread

  @convertIMAPMailboxes: (IMAPMailboxes, callback) ->
    mailboxes = []
    for key of IMAPMailboxes
      mailbox = new Mailbox
        name: key
        selectable: !('NOSELECT' in IMAPMailboxes[key].attribs)
      mailboxes.push mailbox
      if 'HASCHILDREN' in IMAPMailboxes[key].attribs
        for subkey of IMAPMailboxes[key].children
          childMailbox = new Mailbox
            name: subkey
            selectable: !('NOSELECT' in IMAPMailboxes[key].children[subkey].attribs)
          childMailbox.setMailbox mailbox, ->
            mailboxes.push childMailbox
    return callback(mailboxes)

module.exports = Mailbox