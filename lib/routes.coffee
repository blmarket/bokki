module.exports.setRoutes = (app) ->
  app.get "/", (req, res, next) ->
    res.render("index.jade")
