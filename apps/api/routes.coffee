routes = (app) ->

    app.get '/messages', (req, res) ->
      res.sendfile("#{__dirname}/samples/messages.json");

module.exports = routes