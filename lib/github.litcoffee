GitHub API wrapper
------------------

GitHub에서 제공하는 Comments API를 CoffeeScript 함수로 wrapping.

## 요구 라이브러리

* util: Colorized Debugging을 위해 필요하다.

    util = require 'util'

* request: API 요청을 위해 request 라이브러리를 사용한다.

    request = require 'request'

## 전역 변수

* inspect, debug: Colorized debugging

    inspect = (obj) -> util.inspect obj, { colors: true, depth: null }
    debug = (err, res) -> console.log err? && err || inspect(res)

## API 구현

* 댓글 목록 조회

    listComments = (params, cb) ->
      # GitHub 홈페이지에서 제공하는 API skeleton
      url = 'https://api.github.com/repos/:owner/:repo/commits/:sha/comments'
      err = null
      url = url.replace /:(\w+)/g, (txt, key) ->
        err = new Error("param #{key} is required") unless params[key]
        return params[key]
      return cb(err) if err?

      console.log url
      request.get url, (err, res, body) ->
        return cb(err) if err?
        console.log res.statusCode
        console.log body

## 외부 연결 함수

module.exports를 통해 모듈 밖으로 공개된 함수들은 다음과 같다.

아직은 없다.

    listComments {
      sha: '6876ca997c2ee356775330908882d3a199054166'
      owner: 'blmarket'
      repo: 'icpc'
    }, debug
