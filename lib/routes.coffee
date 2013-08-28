_ = require 'underscore'
async = require 'async'
request = require 'request'

config = require '../config'
repository = require './repository'
recents = require './recents'
passport = require('./passport').passport

showRecentFiles = (req, res, next) ->
  repo = null
  recentsha = null
  oldsha = null
  async.waterfall [
    (callback) -> repository.getInstance callback
    (_repo, callback) ->
      repo = _repo
      recents.resolveHead repo, config.refname, callback
    (sha, callback) ->
      recentsha = sha
      recents.resolveOld repo, sha, 100, callback
    (sha, callback) ->
      oldsha = sha
      recents.compareCommit repo, recentsha, oldsha, callback
  ], (err, files) ->
    return next(err) if err?
    res.jsonp(files)

viewFile = (req, res, next) ->
  path = decodeURIComponent(req.param 'path').split('/')
  repository.getInstance (err, repo) ->
    return next(err) if err?
    async.waterfall [
      (callback) ->
        repo.trackPath config.refname, path, callback

      (data, callback) ->
        async.map(data, (item, cb) ->
          repo.repo.object item.id, 'blob', (err, obj) ->
            return cb(err) if err?
            obj.commit = item.commit
            cb(null, obj)
        callback)
    ], (err, results) ->
      return next(err) if err?
      data = _.map results, (item) ->
        { commit: item.commit, code: item.data.toString('utf8') }
      res.render "viewfile.jade", {
        repo: config.repository
        data: JSON.stringify(data)
          .replace(/\u2028/g, '\\u2028')
          .replace(/\u2029/g, '\\u2029')
      }

checkAuth = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect '/login'

tryLogin = passport.authenticate('github', { failureRedirect: '/login', scope: 'public_repo' })

module.exports.setRoutes = (app) ->
  app.get '/0/recents', showRecentFiles
  app.get '/', (req, res, next) -> res.render 'recents.jade'
  app.get "/viewfile/:path", viewFile
  app.get '/login', tryLogin, (req, res) -> res.redirect '/'
  app.get '/login/callback', tryLogin, (req, res) -> res.redirect '/'
