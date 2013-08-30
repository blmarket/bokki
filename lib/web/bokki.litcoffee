Bokki
-----

    BokkiCtrl = ($scope, $resource, $http) ->
      commits = $resource(
        'https://api.github.com/repos/:owner/:repo/commits'
        # { access_token: '27b98e05463bc00b8194fbbef67afaf505add176' }
      )

      data = commits.query {
        owner: 'blmarket', repo: 'icpc', path: 'blmarket/GearsDiv1.cpp'
      }, ->
        shas = (item.sha for item in data)
        console.log shas

      console.log 'hello world'
