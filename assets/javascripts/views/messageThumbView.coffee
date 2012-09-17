Mail.Views.MessageThumbView = Backbone.View.extend
  template: _.template $('#message-thumb-template').html()
  
  render: ->
    this.$el.html this.template(this.model.toJSON())
    return this