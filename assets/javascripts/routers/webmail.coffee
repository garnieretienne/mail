Mail.Routers.Webmail = Backbone.Router.extend

  routes:
    '': 'home'

  initialize: ->
    
    # UI disconnect button
    new Mail.Views.DisconnectButtonView
      el: $('#disconnect')

    this.messages  = new Mail.Collections.MessageList()
    this.mailboxes = new Mail.Collections.MailboxList()

  # Home page with the following components
  # - Mailbox list
  # - Message list
  # - Selected message content
  home: ->

    # Mailbox List
    mailboxNameListView = new Mail.Views.MailboxNameListView
      collection: this.mailboxes
    $('#mailbox-list').html mailboxNameListView.render().el

    # Message List (thumbs)
    messageListView = new Mail.Views.MessageThumbListView
      collection: this.messages
    $('#message-list').html messageListView.render().el
