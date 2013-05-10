path = require 'path'
express = require 'express'
RedisStore = require('connect-redis')(express)

routes = require './routes'
passport = require('./passport').passport

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', path.join(__dirname, '../views')
  app.set 'view engine', 'jade'

  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session({
    secret: 'node-bokki!ASDLKVJDLKJSFD',
    store: new RedisStore()
  })
  app.use passport.initialize()
  app.use passport.session()
  app.use (req, res, next) ->
    res.locals.pretty = true
    res.locals.access_key = req.user || null
    next()
  app.use app.router
  app.use express.static(path.join(__dirname, '../public'))

app.configure 'development', ->
  app.use express.errorHandler()

routes.setRoutes app

module.exports = app
