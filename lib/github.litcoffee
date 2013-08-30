GitHub API wrapper
------------------

GitHub에서 제공하는 Comments API를 CoffeeScript 함수로 wrapping.

## 요구 라이브러리

* util: Colorized Debugging을 위해 필요하다.

    util = require 'util'

* request: API 요청을 위해 request 라이브러리를 사용한다.

    request = require 'request'

## 도우미 함수

* inspect, debug: Colorized debugging

    inspect = (obj) -> util.inspect obj, { colors: true, depth: null }
    debug = (err, res) -> console.log err? && err || inspect(res)

* fillParam: url에 param 입혀주기

    fillParam = (skel, params, callback) ->
      err = null
      ret = skel.replace /:(\w+)/g, (txt, key) ->
        err = new Error("param #{key} is required") unless params[key]
        return params[key]
      return callback(err) if err?
      callback(null, ret)

## API 구현

* 댓글 목록 조회

    listComments = (params, cb) ->
      # GitHub 홈페이지에서 제공하는 API skeleton
      # http://developer.github.com/v3/repos/comments/
      fillParam(
        'https://api.github.com/repos/:owner/:repo/commits/:sha/comments'
        params
        (err, url) ->
          return cb(err) if err?
          request.get url, (err, res, body) ->
            return cb(err) if err?
            cb JSON.parse(body)
      )

* 댓글 작성

    postComment = (params, cb) ->
      # POST /repos/:owner/:repo/commits/:sha/comments
      fillParam(
        "https://api.github.com/repos/:owner/:repo/commits/:sha/comments?access_token=:access_token"
        params
        (err, url) ->
          return cb(err) if err?
          request.post { url: url, body: JSON.stringify(params.form) }, (err, res, body) ->
            return cb(err) if err?
            console.log res.statusCode
            console.log res.headers
            console.log JSON.parse(body)
            cb null, null
      )
      err = null

    findCommits = (params, cb) ->
      # GET /repos/:owner/:repo/commits
      fillParam(
        'https://api.github.com/repos/:owner/:repo/commits'
        params
        (err, url) ->
          return cb(err) if err?
          request.get {
            url: url
            qs: params.query
          }, (err, res, body) ->
            return cb(err) if err?
            data = JSON.parse(body)
            ret = ( commit.sha for commit in data )
            cb null, ret
      )

## 외부 연결 함수

module.exports를 통해 모듈 밖으로 공개된 함수들은 다음과 같다.

아직은 없다.

    # listComments {
    #   sha: '6876ca997c2ee356775330908882d3a199054166'
    #   owner: 'blmarket'
    #   repo: 'icpc'
    # }, debug

    # postComment {
    #   owner: 'blmarket'
    #   repo: 'icpc'
    #   sha: '6876ca997c2ee356775330908882d3a199054166'
    #   access_token: '27b98e05463bc00b8194fbbef67afaf505add176'
    #   form: {
    #     body: 'Generated Comment 2'
    #     path: 'blmarket/GearsDiv1.cpp'
    #   }
    # }, debug

    # findCommits {
    #   owner: 'blmarket'
    #   repo: 'icpc'
    #   query: {
    #     access_token: '27b98e05463bc00b8194fbbef67afaf505add176'
    #     path: 'blmarket/GearsDiv1.cpp'
    #   }
    # }, debug

    module.exports.findCommits = findCommits
