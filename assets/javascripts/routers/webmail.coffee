Mail.Routers.Webmail = Backbone.Router.extend

  routes:
    '': 'home'

  initialize: ->
    this.messages = new Mail.Collections.MessageList()
    this.messages.fetch()

  # Home page with the following components
  # - Mailbox list
  # - Message list
  # - Selected message content
  home: ->

    # Message List (thumbs)
    messageListView = new Mail.Views.MessageThumbListView
      collection: this.messages
    $('#message-list').html messageListView.el
