module.exports = (grunt) ->
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json')
    coffee: {
      compile: {
        options: {
          bare: false
        }
        files: {
          'public/dist/plugin.js': 'public/collector/plugin.coffee'
        }
      }
    }
    concat: {
      options: { separator: ';' }
      dist: {
        src: [
          'public/collector/ba-postmessage.min.js'
          'public/collector/mall.js'
          'public/dist/plugin.js'
        ]
        dest: 'public/dist/production.js'
      }
    }
    uglify: {
      options: {
        mangle: {} # default option, set to false if you wanna preserve class names.
      }
      my_target: {
        files: {
          'public/dist/production.min.js' : [
            'public/collector/ba-postmessage.min.js'
            'public/collector/mall.js'
            'public/dist/plugin.js'
          ]
        }
      }
    }
    jade: {
      compile: {
        options: {
          pretty: true
        }
        files: {
          'public/dist/example.html': [ 'docs/example.jade' ]
        }
      }
    }
  }

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-jade'

  grunt.registerTask 'uncompressed', [ 'coffee', 'concat' ]
  grunt.registerTask 'default', [ 'coffee', 'uglify' ] # uglify supports concat, so we don't use it.
