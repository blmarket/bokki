request = require 'request'

url = 'https://api.github.com/repos/:owner/:repo/commits/:sha/comments'

params = {
  owner: 'blmarket',
  repo: 'icpc',
  sha: 'f03ecbc1522f3fb4731f73079ff2ef3d8458f53a'
}

myurl = url.replace /\:(\w+)/g, (match, key) ->
  return params[key]

console.log myurl

request.get myurl, (err, res, body) ->
  throw err if err
  console.log res.statusCode
  console.log res.headers
  console.log body

