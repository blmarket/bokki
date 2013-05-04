config = require '../config'
repository = require './repository'

getOldSha = (repo, 

repository.createRepo config.repopath, (err, repo) ->
  throw err if err?
  repo.repo.reference config.refname, null, (err, res) ->
    throw err if err?
    sha = res.target
    console.log sha
    onItem = (err, commit, restcount) ->
      #
    repo.trackCommit sha, 1000, onItem, (err, sha) ->
      console.log "End with %s", err, sha

