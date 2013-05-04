_ = require 'underscore'
async = require 'async'

config = require '../config'
repository = require './repository'

resolveHead = (repo, refname, callback) ->
  repo.repo.reference refname, null, (err, res) ->
    return callback(err) if err?
    callback(null, res.target)

resolveOld = (repo, sha, count, callback) ->
  repo.trackCommit(
    sha, count
    (err) ->
    callback
  )

compareCommit = (repo, sha1, sha2, callback) ->
  resolveTree = (sha, cb) ->
    repo.repo.object sha, 'commit', (err, commit) ->
      return cb(err) if err?
      cb(null, commit.tree)

  compareTrees = (currentpath, sha1, sha2, callback) ->
    getTree = (sha, cb) ->
      return cb(null, null) if !sha
      repo.repo.object sha, 'tree', cb

    compareEntries = (tree1, tree2, callback) ->
      reduceEntries = (entries) ->
        return _.reduce(
          entries
          (memo, item) ->
            memo[item.id] = item
            return memo
          {}
        )

      oldEntries = (tree2 && tree2.entries) || []
      oldEntryMap = reduceEntries oldEntries
      async.each(
        tree1.entries
        (item, cb) ->
          return cb() if oldEntryMap[item.id]
          if item.type == 'tree'
            rhs = _.find oldEntries, (iter) ->
              return iter.name == item.name
            rid = null
            if rhs && rhs.type == 'tree'
              rid = rhs.id
            return compareTrees(currentpath + item.name + '/', item.id, rid, cb)
          console.log currentpath + item.name
          return cb()
        (err) ->
          callback(err)
      )

    async.parallel [
      (cb1) -> getTree(sha1, cb1)
      (cb2) -> getTree(sha2, cb2)
    ], (err, objects) ->
      callback(err) if err?
      compareEntries objects[0], objects[1], callback
  
  async.parallel [
    (cb1) -> resolveTree(sha1, cb1)
    (cb2) -> resolveTree(sha2, cb2)
  ], (err, trees) ->
    return callback(err) if err?
    compareTrees '/', trees[0], trees[1], callback

#repository.createRepo config.repopath, (err, repo) ->
#  throw err if err?
#  repo.repo.reference config.refname, null, (err, res) ->
#    throw err if err?
#    sha = res.target
#    console.log sha
#    onItem = (err, commit, restcount) ->
#      #
#    repo.trackCommit sha, 1000, onItem, (err, sha) ->
#      console.log "End with %s", err, sha

module.exports.resolveHead = resolveHead
module.exports.resolveOld = resolveOld
module.exports.compareCommit = compareCommit
