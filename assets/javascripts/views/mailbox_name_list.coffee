Mail.Views.MailboxNameListView = Backbone.View.extend
  tagName: "ul"

  initialize: ->
    _.bindAll this, 'render', 'renderMailboxName', 'removeMailboxName'
    this.collection.on 'reset',  this.render
    this.collection.on 'add',    this.renderMailboxName
    this.collection.on 'remove', this.removeMailboxName
  
  # Render all mailboxes.
  render: ->
    _this = this
    this.$el.html ''
    children = {}
    this.collection.each (mailbox) ->
      if !mailbox.getParent()
        _this.renderMailboxName mailbox
      else
        index = _this.getIndex mailbox
        children[index] ||= []
        children[index].push mailbox
    for index of children
      for child in children[index]
        _this.renderChildMailboxName child
    return this

  # Return the child index.
  # (Parent > Child1 > Child2 => index of Child2 is 2)
  getIndex: (mailbox, index) ->
    index = 0 if !index
    parent = mailbox.getParent()
    if parent 
      index++
      this.getIndex parent, index
    else
      return index

  # Render one specified mailbox.
  # renderMailboxName() can be call by adding 
  # a child mailbox to the collection.
  renderMailboxName: (mailbox) ->
    if mailbox.getParent()
      this.renderChildMailboxName mailbox
      return
    mailboxNameView = new Mail.Views.MailboxNameView
      model: mailbox
    this.$el.append mailboxNameView.render().el

  # Render one specified child mailbox.
  # If the parent mailbox has no <ul> tag (append when added by event), create it.
  renderChildMailboxName: (mailbox) ->
    mailboxNameView = new Mail.Views.MailboxNameView
      model: mailbox
    parent = mailbox.getParent()
    parentList = this.$el.find("#mailbox-#{parent.id} ul")
    if parentList.length == 0
      this.$el.find("#mailbox-#{parent.id}").append('<ul>')
      this.$el.find("#mailbox-#{parent.id} ul").append mailboxNameView.render().el
    else
      parentList.prepend mailboxNameView.render().el  

  # Remove from the DOM one specified mailbox.
  removeMailboxName: (mailbox) ->
    this.$el.find("#mailbox-#{mailbox.id}").remove()