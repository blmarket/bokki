_ = require 'underscore'
path = require 'path'
step = require 'step'
gitteh = require 'gitteh'

config = {
  repopath: "/home/blmarket/proj/icpc/",
  refname: "refs/heads/master",
  path: [ "blmarket", "PenguinEmperor.cpp" ]
}

gitteh.openRepository (config.repopath), (err, repo) ->
  throw err if err

  track_commit2 = (sha, count, onItem, onEnd) ->
    return onEnd(null) if count == 0 || !sha
    repo.object sha, 'commit', (err, commit) ->
      return onEnd(err) if err
      onItem(null, commit)
      track_commit2 commit.parents[0], count-1, onItem, onEnd

  # for given sha and count, returns up to count tree object of commits 
  # of ancestors of sha
  track_commit = (sha, count, callback) ->
    list = []
    track_commit2(sha, count, (err, item) ->
      list.unshift(item.tree) if !err
    , (err) ->
      callback(null, list)
    )

  resolve_object = (sha, path, callback) ->
    return callback null, null if !path
    repo.object sha, 'tree', (err, tree) ->
      return callback(err) if err
      pick = _.find(tree.entries, (item) -> item.name == path[0])
      path.shift()
      return callback(new Error("no such object")) if !pick
      return callback(null, pick) if path.length == 0
      resolve_object pick.id, path, callback

  repo.reference config.refname, null, (err, res) ->
    throw err if err

    list = []
    track_commit2 res.target, 1000, (err, item) ->
      return if err
      resolve_object item.tree, _.clone(config.path), (err, res) ->
        return if err || !res
        list.unshift res
    , (err) ->
      console.log err
      console.log list

