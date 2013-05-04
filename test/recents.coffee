require 'mocha'
should = require 'should'

config = require '../config'
libs = require '../index'
repository = libs.repository
recents = libs.recents

describe 'recent module', ->
  repo = null
  recentsha = '76c7b60532d963ab25a02d1c0dbca3806e85f193'
  expectedoldsha = 'ca619e3a061beceb0ef87faa85c8bc3d0d6bbb77'

  before (done) ->
    repository.createRepo config.repopath, (err, res) ->
      should.not.exist(err)
      repo = res
      done()

  it 'resolve head', (done) ->
    recents.resolveHead repo, config.refname, (err, sha) ->
      should.not.exist err
      should.exist sha
      done()

  it 'resolves old commit', (done) ->
    recents.resolveOld repo, recentsha, 1000, (err, sha) ->
      should.not.exist err
      expectedoldsha.should.eql sha
      done()

  it 'compare 2 shas', (done) ->
    recents.resolveOld repo, recentsha, 100, (err, sha) ->
      should.not.exist(err)
      recents.compareCommit repo, recentsha, sha, (err, files) ->
        should.not.exist(err)
        console.log files
        done()
