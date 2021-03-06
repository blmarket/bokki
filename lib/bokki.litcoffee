Bokki
-----

## 도우미 함수들

* `async`, _ : async의 parallel과 underscore의 extend 함수를 빌려 쓴다.
underscore는 coffee로 비슷하게 만들 수 있지만 그냥... 귀차늠.

* `base64_decode` : node에선 base64 decode를 쉽게 할 수 있지만 client
side에서는 Buffer가 없으므로 자체 구현해서 쓴다. github에서 blob content가
base64 encoded로 돌아오는 경우가 있어서 사용함.

    base64_decode = (input) ->
      keyStr = "ABCDEFGHIJKLMNOP" +
        "QRSTUVWXYZabcdef" +
        "ghijklmnopqrstuv" +
        "wxyz0123456789+/" +
        "="

      output = ""
      chr1 = chr2 = chr3 = 0
      enc1 = enc2 = enc3 = enc4 = 0

      input = input.replace /[^A-Za-z0-9\+\/\=]/g, ''

      for i in [0...input.length] by 4
        enc1 = keyStr.indexOf input.charAt(i)
        enc2 = keyStr.indexOf input.charAt(i+1)
        enc3 = keyStr.indexOf input.charAt(i+2)
        enc4 = keyStr.indexOf input.charAt(i+3)

        chr1 = (enc1 << 2) | (enc2 >> 4)
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
        chr3 = ((enc3 & 3) << 6) | enc4

        output = output + String.fromCharCode(chr1)
        output = output + String.fromCharCode(chr2) if enc3 != 64
        output = output + String.fromCharCode(chr3) if enc4 != 64

      return output

* myPick : underscore의 pick과 동일함.

    myPick = (obj, picks...) ->
      ret = {}
      ret[pick] = obj[pick] for pick in picks
      return ret

* Our app configuration.

$resource를 쓰기 위해 ngResource를 dependency로 추가해야 하고,
diff view를 만들기 위해 compile을 사용하고 있다.

    angular.module 'bokki', [ 'ngResource' ], ($compileProvider) ->
      $compileProvider.directive 'compile', ($compile) ->
        (scope, element, attrs) ->
          scope.$watch(
            (scope) ->
              return scope.$eval(attrs.compile)
            (value) ->
              element.html(scope.calc_diff(value))
              $compile(element.contents())(scope)
          )

## 메인 함수

BokkiCtrl은 angularjs Controller임. $scope, $resource, $http를 사용함.

    bokki = null
    BokkiCtrl = ($scope, $compile, $resource, $http) ->
      bokki = $scope

      commits_api = $resource(
        'https://api.github.com/repos/:owner/:repo/commits/:sha'
      )
      blob_api = $resource(
        'https://api.github.com/repos/:owner/:repo/git/blobs/:sha'
      )

      calc_diff = ->
        return unless $scope.revs
        idx = $scope.rev_index
        left = difflib.stringAsLines($scope.revs[idx-1].content)
        right = difflib.stringAsLines($scope.revs[idx].content)
        contextSize = null # 전체 diff일 경우 null, 근처 n줄만 보고 싶으면 n.

        sm = new difflib.SequenceMatcher(left, right)
        return diffview.buildView {
          baseTextLines: left
          newTextLines: right
          opcodes: sm.get_opcodes()
          baseTextName: "Revision #{idx-1}"
          newTextName: "Revision #{idx}"
          contextSize: contextSize
          viewType: 1
        }

      $scope.calc_diff = calc_diff
      $scope.path = null
      $scope.owner = null
      $scope.repo = null
      $scope.revs = null
      $scope.rev_index = null

      $scope.pressLeft = ->
        return unless $scope.revs
        $scope.rev_index = if $scope.rev_index > 0 then $scope.rev_index - 1 else 0

      $scope.pressRight = ->
        return unless $scope.revs
        $scope.rev_index = if $scope.rev_index < $scope.revs.length then $scope.rev_index + 1 else $scope.revs.length

로드 함수. 아래 단락이 이 항목의 하위항목임을 밝혀야 하는데...

      $scope.load = (owner, repo, path) ->
        [ $scope.owner, $scope.path, $scope.repo ] = [ owner, path, repo ]

        # 해당 path가 포함되어 있는 commit들을 찾는다.
        commits = commits_api.query myPick($scope, 'owner', 'repo', 'path'), ->
          toTask = (commit_sha) ->
            return (cb) ->
              ret = commits_api.get _.extend(myPick($scope, 'owner', 'repo'), { sha: commit_sha }), ->
                for file in ret.files
                  if file.filename == $scope.path
                    blob_sha = file.sha
                    blob_obj = blob_api.get _.extend(myPick($scope, 'owner', 'repo'), { sha: blob_sha }), ->
                      if blob_obj.encoding == 'base64'
                        blob_obj.content = base64_decode(blob_obj.content)
                      cb(null, {
                        commit: commit_sha
                        blob: file.sha
                        content: blob_obj.content
                      })
                    return

          commits = commits.reverse()
          tasks = (toTask(item.sha) for item in commits)

각 Commit에 대해 Blob들을 꺼내왔으면 이것들을 revision으로 칭한다.
전체 revision 데이터는 통짜로 $scope.revs에 들어있게 되며, 이 통으로
넣는게 너무 커지면 한번에 다 긁는게 아니라, 필요한 커밋만 긁는 식으로
개선해나갈 생각이다.(현재 보는 커밋 +-5개 커밋만 blob을 긁어오고
기다렸다가 사용자가 이동하면 거기에 맞춰 근처 blob들을 새로 캐시..)

          async.parallel tasks, (err, revs) ->
            $scope.revs = revs # 이거 왜 $apply 없이 해도 되지?
            $scope.rev_index = 0
            console.log revs

왼쪽 오른쪽 키바인딩을 설정한다. angularJS 밖에서 호출하는 함수이니
$apply로 감싸줘야 변경된 내용이 적용된다.

    $(window).keyup (ev) ->
      return unless bokki # don't work if bokki is not up.
      bokki.$apply( -> bokki.pressLeft()) if ev.keyCode == 37
      bokki.$apply( -> bokki.pressRight()) if ev.keyCode == 39

