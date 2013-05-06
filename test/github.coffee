require 'mocha'
should = require 'should'
_ = require 'underscore'
request = require 'request'
cheerio = require 'cheerio'

describe 'login page', ->
  it 'displays github login page', (done) ->
    @timeout(19000)
    request.get 'http://localhost:3000/login', (err, res, body) ->
      should.not.exist(err)

      $ = cheerio.load(body)
      inputs = $('form input')

      form = {}
      for i in inputs
        form[i.attribs.name] = i.attribs.value
      form.login = 'blemx'
      form.password = 'naver0com'

      request.post({
        uri: 'https://github.com/session'
        form: form
        followAllRedirects: true
      }, (err, res, body) ->
        should.not.exist err
        $ = cheerio.load body

        form = $('form').eq(1)
        inputs = form.find('input')
        form = {}
        for i in inputs
          form[i.attribs.name] = i.attribs.value
        form.authorize = '1'

        request.post({
          uri: 'https://github.com/login/oauth/authorize'
          form: form
          followAllRedirects: true
        }, (err, res, body) ->
          should.not.exist err
          body.should.eql 'OK'
          done()
        )
      )

  it 'supports revoke application', (done) ->
    @timeout(9000)
    request.get 'https://github.com/settings/applications', (err, res, body) ->
      $ = cheerio.load(body)
      token = null
      $('meta').each (i, item) ->
        token = item.attribs.content if item.attribs.name == 'csrf-token'
      url = $('.js-remove-item')[0].attribs.href
      request.del({
        uri: 'https://github.com' + url
        followAllRedirects: true
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
          'X-CSRF-Token': token
        }
      }, (err, res, body) ->
        should.not.exist err
        res.statusCode.should.eql 200
        done()
      )
