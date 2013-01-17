_ = require 'underscore'
step = require 'step'

repository = require './repo'

# I don't like configs are here...
config = {
  repopath: "/home/blmarket/Proj/icpc/",
  refname: "refs/heads/master",
  path: [ "blmarket", "RotatingBot.cpp" ]
}

module.exports.setRoutes = (app) ->
  app.get "/", (req, res, next) ->
    repository.createRepo config.repopath, (err, repo) ->
      return next(err) if err
      repo.test config.refname, config.path, (err, data) ->
        return next(err) if err
        step( ->
          group = @group()
          for item in data
            repo.repo.object item.id, 'blob', group()
          return
        , (err, results) ->
          data = _.map(results, (item) ->
            return item.data.toString('utf8')
          )
          res.render "index.jade", { data: data }
        )
