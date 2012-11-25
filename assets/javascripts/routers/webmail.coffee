Mail.Routers.Webmail = Backbone.Router.extend

  routes:
    '': 'home'

  initialize: ->
    
    # UI disconnect button
    new Mail.Views.DisconnectButtonView
      el: $('#disconnect')

    this.messages = new Mail.Collections.MessageList()

  # Home page with the following components
  # - Mailbox list
  # - Message list
  # - Selected message content
  home: ->

    # Message List (thumbs)
    messageListView = new Mail.Views.MessageThumbListView
      collection: this.messages
    $('#message-list').html messageListView.render().el
