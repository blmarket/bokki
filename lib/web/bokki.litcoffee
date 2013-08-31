Bokki
-----

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

    BokkiCtrl = ($scope, $resource, $http) ->
      commits_api = $resource(
        'https://api.github.com/repos/:owner/:repo/commits/:sha'
      )
      blob_api = $resource(
        'https://api.github.com/repos/:owner/:repo/git/blobs/:sha'
      )

      $scope.path = 'blmarket/GearsDiv1.cpp'
      $scope.owner = 'blmarket'
      $scope.repo = 'icpc'

      console.log $scope

      data = commits_api.query {
        owner: 'blmarket', repo: 'icpc', path: $scope.path
      }, ->
        toTask = (sha) ->
          return (cb) ->
            ret = commits_api.get { owner: 'blmarket', repo: 'icpc', sha: sha }, ->
              for file in ret.files
                if file.filename == $scope.path
                  blob_sha = file.sha
                  blob_obj = blob_api.get { owner: 'blmarket', repo: 'icpc', sha: blob_sha }, ->
                    if blob_obj.encoding == 'base64'
                      blob_obj.content = base64_decode(blob_obj.content)
                    cb(null, {
                      commit: sha
                      blob: file.sha
                      content: blob_obj.content
                    })
                  return

        tasks = (toTask(item.sha) for item in data)

        async.parallel tasks, (err, blobs) ->
          console.log blobs
