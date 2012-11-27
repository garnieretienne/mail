Mail.Models.Mailbox = Backbone.Model.extend

  # Return the mailbox parent if defined
  getParent: ->
    if this.get('mailboxId') && this.collection
      parent = this.collection.get this.get('mailboxId')
      return parent
    else
      return null

  # Return the mailbox children if defined
  getChildren: ->
    _this = this
    if this.collection
      return this.collection.where mailboxId: _this.get('id')
    else
      return []