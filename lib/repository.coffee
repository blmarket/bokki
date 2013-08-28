_ = require 'underscore'
path = require 'path'
gitteh = require 'gitteh'

config = require '../config'
instance = null

createRepo = (path, callback) ->
  class Repo
    constructor: (@repo) ->

    trackCommit: (sha, count, onItem, onEnd) ->
      return onEnd(null, sha) if count == 0 || !sha
      @repo.object sha, 'commit', (err, commit) =>
        return onEnd(err) if err
        onItem null, commit, count
        @trackCommit commit.parents[0], count-1, onItem, onEnd

    resolveObject: (sha, path, callback) ->
      return callback null, null if !path
      @repo.object sha, 'tree', (err, tree) =>
        return callback(err) if err
        pick = _.find(tree.entries, (item) -> item.name == path[0])
        path.shift()
        return callback(new Error("no such object")) if !pick
        return callback(null, pick) if path.length == 0
        @resolveObject pick.id, path, callback

    trackPath: (refname, path, callback) ->
      @repo.reference refname, null, (err, res) =>
        return callback(err) if err

        list = new Array(1001)
        @trackCommit res.target, 1000, (err, item, index) =>
          return callback(err) if err
          @resolveObject item.tree, _.clone(path), (err, res) ->
            # Err, no result or there exists same object...
            return if err || !res
            list[index] = res
            list[index].commit = item.id
        , (err) ->
          list = _.uniq(_.compact(list), true, (item) -> return item.id)
          callback err, list

  gitteh.openRepository path, (err, repo) ->
    return callback err if err
    return callback null, new Repo(repo)

getInstance = (callback) ->
  return callback(null, instance) if instance?
  createRepo config.repopath, (err, repo) ->
    return callback(err) if err?
    instance = repo
    callback(null, instance)

module.exports.createRepo = createRepo
module.exports.getInstance = getInstance
