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
  repo.repo.object sha1, 'commit', (err, commit1) ->
    console.log commit1

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
