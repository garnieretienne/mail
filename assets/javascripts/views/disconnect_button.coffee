Mail.Views.DisconnectButtonView = Backbone.View.extend

  events: 
    'click': 'disconnect'

  # Log out the user and diconnect him from the app
  # by sending a DELETE /sessions http request
  # Use of ajax for browser support
  disconnect: ->
    $.ajax
      url: '/sessions'
      type: 'DELETE'
      success: ->
        window.location = "/"