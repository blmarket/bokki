GitHub API wrapper
------------------

GitHub에서 제공하는 Comments API를 CoffeeScript 함수로 wrapping.

## 전역 변수

아직은 없다.

## API 구현

* 댓글 목록 조회

    listComments = (params, cb) ->
      # GitHub 홈페이지에서 제공하는 API skeleton
      url = 'https://api.github.com/repos/:owner/:repo/commits/:sha/comments'


## 외부 연결 함수

module.exports를 통해 모듈 밖으로 공개된 함수들은 다음과 같다.

아직은 없다.
