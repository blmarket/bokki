passport = require 'passport'
GithubStrategy = require('passport-github').Strategy

config = require '../config'

GITHUB_CLIENT_ID = '42a5e0fa38b36d348cf8'
GITHUB_SECRET = '978660cbb34627edd3a65e2a536058f7665accec'

passport.use(new GithubStrategy(
  {
    clientID: GITHUB_CLIENT_ID,
    clientSecret: GITHUB_SECRET,
    callbackURL: config.hostname + '/login/callback'
  }
  (accessToken, refreshToken, profile, done) -> # save access token as userinfo
    done(null, accessToken)
))

passport.serializeUser (token, done) -> # we don't need other informations
  done(null, token)

passport.deserializeUser (token, done) -> # session contains only access Token
  done(null, token)

module.exports.passport = passport
