routes = (app) ->

    app.get '/', (req, res) ->
      res.render "#{__dirname}/views/index",
        title: 'Mail'

module.exports = routes