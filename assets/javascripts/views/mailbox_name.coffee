Mail.Views.MailboxNameView = Backbone.View.extend
  template:  _.template Mail.Templates.mailboxNameTemplate
  className: 'mailbox'
  tagName:   "li"

  initialize: ->
    _.bindAll this, 'render'

  # Render a single message thumb.
  # Message thumbs get an 'id' equal to their UID.
  render: ->
    this.model.set 'children', this.model.getChildren().length
    this.$el.attr('id', "mailbox-#{this.model.get('id')}").html this.template(this.model.toJSON())
    return this