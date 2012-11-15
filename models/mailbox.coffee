# Sequelized Models
# SequelizedModels  = require(__dirname + '/sequelize/sequelizedModels')
# SequelizedMailbox = SequelizedModels.Mailbox

# Migration
# SequelizedModels.migrate()

class Mailbox
  # @prototype: SequelizedMailbox.build()
  # @find: (attributes, callback) ->
  #   _this = @
  #   SequelizedMailbox.find(attributes).success (sequelizedMailbox) ->
  #     if sequelizedMailbox
  #       mailbox = SequelizedModels.convert(sequelizedMailbox, Mailbox)
  #       return callback(mailbox)
  #     else return callback(null)
  # @sync: (attributes) ->
  #   return SequelizedMailbox.sync attributes

  constructor: (attributes) ->
    @cachedAttributes = ['name', 'selectable', 'uidValidity']
    @[key] = value for key, value of attributes
    @setDefaults()

  setDefaults: ->
    @selectable = true if @selectable == (null || undefined)
    if @messages
      @messages.total = 0 if !@messages.total
      @messages.unread = 0 if !@messages.unread
    else
      @messages =
        total: 0
        unread: 0

  # TODO: manage parents
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