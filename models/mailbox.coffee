# Sequelized Models
SequelizedModels  = require(__dirname + '/sequelize/sequelizedModels')
SequelizedMailbox = SequelizedModels.Mailbox

class Mailbox
  @prototype: SequelizedMailbox.build()
  @find: (attributes) ->
    return SequelizedMailbox.find attributes
  @sync: (attributes) ->
    return SequelizedMailbox.sync attributes

  constructor: (attributes) ->
    @[key] = value for key, value of attributes
    @setDefaults()

  setDefaults: ->
    @selectable = true if @selectable == null
    #@hasChilds  = false if @hasChilds == undefined
    #@hasParent  = false if @hasParent == undefined
    if @messages
      @messages.total = 0 if !@messages.total
      @messages.unread = 0 if !@messages.unread
    else
      @messages =
        total: 0
        unread: 0

module.exports = Mailbox