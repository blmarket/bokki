_ = require 'underscore'
async = require 'async'
request = require 'request'
repository = require './repository'

# I don't like configs are here...
config = {
  repopath: "/home/blmarket/Proj/icpc/",
  refname: "refs/heads/master",
  path: [ "blmarket", "TheSquareRootDilemma.cpp" ]
}

module.exports.setRoutes = (app) ->
  app.get "/", (req, res, next) ->
    repository.createRepo config.repopath, (err, repo) ->
      return next(err) if err?
      async.waterfall [
        (callback) ->
          repo.test config.refname, config.path, callback

        (data, callback) ->
          async.map(data, (item, cb) ->
            repo.repo.object item.id, 'blob', cb
          callback)
      ], (err, results) ->
        return next(err) if err?
        data = _.map results, (item) ->
          item.data.toString('utf8')
        res.render "index.jade", {
          pretty: true,
          data: JSON.stringify(data)
            .replace(/\u2028/g, '\\u2028')
            .replace(/\u2029/g, '\\u2029')
        }
