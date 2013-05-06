passport = require 'passport'
GithubStrategy = require('passport-github').Strategy

GITHUB_CLIENT_ID = '42a5e0fa38b36d348cf8'
GITHUB_SECRET = '978660cbb34627edd3a65e2a536058f7665accec'

passport.use(new GithubStrategy(
  {
    clientID: GITHUB_CLIENT_ID,
    clientSecret: GITHUB_SECRET,
    callbackURL: 'http://localhost:3000/login/callback'
  }
  (accessToken, refreshToken, profile, done) ->
    console.log profile
    done(null, profile)
))

module.exports.passport = passport