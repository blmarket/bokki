Bokki
-----

    BokkiCtrl = ($scope, $resource, $http) ->
      commits = $resource(
        'https://api.github.com/repos/:owner/:repo/commits/:sha'
        # { access_token: '27b98e05463bc00b8194fbbef67afaf505add176' }
      )

      # commitInfo = $resource(
      #   'https://api.github.com/repos/:owner/:repo/commits/:sha'
      # )

      file_path = 'blmarket/GearsDiv1.cpp'

      data = commits.query {
        owner: 'blmarket', repo: 'icpc', path: file_path
      }, ->
        toTask = (sha) ->
          return (cb) ->
            ret = commits.get { owner: 'blmarket', repo: 'icpc', sha: sha }, ->
              for file in ret.files
                return cb(null, {
                  commit: sha
                  blob: file.sha
                }) if file.filename == file_path

        tasks = (toTask(item.sha) for item in data)

        async.parallel tasks, (err, blobs) ->
          console.dir blobs

      console.log 'hello world'
