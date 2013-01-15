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

  # for given sha and count, returns up to count tree object of commits 
  # of ancestors of sha
  track_commit = (sha, count, callback) ->
    return callback(null, []) if count == 0 || !sha
    repo.object sha, 'commit', (err, commit) ->
      return callback(err) if err

      # FIXME: tracking only first parent now, should track all the parents
      track_commit commit.parents[0], count-1, (err, list) ->
        list.push commit.tree
        return callback null, list

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

    track_commit res.target, 1000, (err, list) ->
      throw err if err
      console.log list

      resolve_object list[1], config.path, (err, res) ->
        return console.log err if err
        console.log res

        repo.object res.id, res.type, (err, res) ->
          console.log err
          console.log res

###
    console.log "commit sha: #{res.target}"
    repo.object res.target, 'commit', (err, commit) ->
      throw err if err
      console.log commit

      console.log "tree: #{commit.tree}"
      repo.object commit.tree, 'tree', (err, tree) ->
        throw err if err
        
        console.log tree
###
