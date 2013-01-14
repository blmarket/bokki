path = require 'path'
gitteh = require 'gitteh'

gitteh.openRepository (path.join __dirname, '../'), (err, repo) ->
  throw err if err

  console.log gitteh.NativeRepository.prototype

  repo.reference 'refs/heads/master', null, (err, res) ->
    throw err if err

    console.log "commit sha: #{res.target}"
    repo.object res.target, 'commit', (err, commit) ->
      throw err if err

      console.log "tree: #{commit.tree}"
      repo.object commit.tree, 'tree', (err, tree) ->
        throw err if err
        
        console.log tree
