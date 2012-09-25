Mail.Views.MessageThumbListView = Backbone.View.extend

  initialize: ->
    _.bindAll this, 'render', 'renderMessageThumb', 'removeMessageThumb'
    this.collection.on 'reset', this.render
    this.collection.on 'add', this.renderMessageThumb
    this.collection.on 'remove', this.removeMessageThumb
  
  # Render all message thumbs.
  render: ->
    this.$el.html ''
    this.collection.each this.renderMessageThumb
    return this

  # Render one specified message thumb.
  renderMessageThumb: (message) ->
    messageThumbView = new Mail.Views.MessageThumbView
        model: message
    this.$el.prepend messageThumbView.render().el

  # Remove from the DOM one specified message thumb.
  removeMessageThumb: (message) ->
    this.$el.find("#message-thumb-#{message.get('uid')}").remove()