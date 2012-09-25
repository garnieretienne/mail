routes = (app, io) ->

    app.get '/', (req, res) ->
      res.render "#{__dirname}/views/index",
        title: 'Mail'

    app.get '/test/socket', (req, res) ->
      io.sockets.emit "testing", "Hello Socket!"
      res.send 200

module.exports = routes