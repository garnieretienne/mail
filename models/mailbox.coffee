# Sequelized Models
SequelizedModels  = require(__dirname + '/sequelize/sequelizedModels')
SequelizedMailbox = SequelizedModels.Mailbox

# Migration
SequelizedModels.migrate()

class Mailbox
  @prototype: SequelizedMailbox.build()
  @find: (attributes, callback) ->
    _this = @
    SequelizedMailbox.find(attributes).success (sequelizedMailbox) ->
      if sequelizedMailbox
        mailbox = SequelizedModels.convert(sequelizedMailbox, Mailbox)
        return callback(mailbox)
      else return callback(null)
  @sync: (attributes) ->
    return SequelizedMailbox.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes
    @setDefaults()

  setDefaults: ->
    @selectable = true if @selectable == null
    if @messages
      @messages.total = 0 if !@messages.total
      @messages.unread = 0 if !@messages.unread
    else
      @messages =
        total: 0
        unread: 0

module.exports = Mailbox