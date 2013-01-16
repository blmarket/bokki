repo = require './repo'

config = {
  repopath: "/home/blmarket/proj/icpc/",
  refname: "refs/heads/master",
  path: [ "blmarket", "RotatingBot.cpp" ]
}

module.exports.setRoutes = (app) ->
  app.get "/", (req, res, next) ->
    repo.createRepo config.repopath, (err, repo) ->
      return next(err) if err
      repo.test config.refname, config.path, (err, data) ->
        return next(err) if err
        res.render "index.jade", { data: data }
