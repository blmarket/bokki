module.exports = (grunt) ->
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json')
    coffee: {
      compile: {
        options: {
          bare: true
        }
        files: {
          'public/bokki-nodep.js': 'lib/bokki.litcoffee'
        }
      }
    }
    bower: { install: {} }
    concat: {
      options: { separator: ';\n' }
      dist: {
        src: [
          'bower_components/async/lib/async.js'
          'bower_components/underscore/underscore-min.js'
          'contrib/diffview.js'
          'contrib/difflib.js'
          'public/bokki-nodep.js'
        ]
        dest: 'public/bokki.js'
      }
    }
    jade: {
      compile: {
        options: {
          pretty: true
        }
        files: {
          'public/main.html': [ 'views/main.jade' ]
        }
      }
    }
  }

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-bower-task'

  grunt.registerTask 'default', [ 'bower', 'coffee', 'jade', 'concat' ]
