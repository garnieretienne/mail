Mail.Views.MessageThumbView = Backbone.View.extend
  template: _.template Mail.Templates.messageThumbTemplate
  className: 'message-thumb'


  initialize: ->
    _.bindAll this, 'render', 'buildClassName'

  # Build the class aatribute for this message thumb.
  # * Message get a class of 'unread' if it not marked with the '\Seen' flag.
  buildClassName: ->
    className = []
    if !this.model.flagged('\\Seen')
      className.push 'unread'
    return className.join(' ')
  
  # Render a single message thumb.
  # Message thumbs get an 'id' equal to their UID.
  render: ->
    className = this.buildClassName()
    this.$el.attr('id', "message-thumb-#{this.model.get('uid')}").addClass(className).html this.template(this.model.toJSON())
    this.loadAvatar()
    return this

  # Load avatars from gravatars
  loadAvatar: ->
    _this     = this
    $gravatar = this.$el.find(".gravatar")
    src       = $gravatar.attr('data-src')
    name      = $gravatar.attr('data-name')

    if src
      img = new Image()
      $(img)
        .load ->
          $(this)
            .attr('alt', name)
            .addClass("img-rounded from-avatar")
          _this.$el.find('.from').prepend this
        .attr('src', src)