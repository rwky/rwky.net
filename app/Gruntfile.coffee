module.exports = (grunt) ->
  
    # Project configuration.
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        coffee:
            static:
                files:
                    'public/js/main.js': 'public/js/main.coffee'
            routes:
                expand: true
                cwd: 'routes/'
                src: ['*.coffee']
                dest: 'routes/'
                ext: '.js'
            app:
                expand: true
                cwd: '.'
                src: ['*.coffee']
                dest: './'
                ext: '.js'
            config:
                expand: true
                cwd: 'config/'
                src: ['*.coffee']
                dest: 'config/'
                ext: '.js'
        watch:
            scripts:
                files: ['routes/*.coffee', '*.coffee', 'public/js/*.coffee']
                tasks: ['coffee:static', 'shell:restart']
                options:
                    nospawn: true
        shell:
            restart:
                command: "passenger-config restart-app --ignore-passenger-not-running /home"
                options:
                    failOnError: false
                    stdout: true
                    stderr: true
            lint:
                command: "node_modules/coffeelint/bin/coffeelint -f ./coffeelint.json " + [
                        'routes/*.coffee'
                        'public/js/*.coffee'
                        '*.coffee'
                    ].join(' ')
                options:
                    stdout: true
            version:
                command: """
                echo 'module.exports = #{new Date().getTime()};' > version.js
                """

    grunt.event.on 'watch', (action, filepath) ->
        files = [{}]
        files[0][filepath.replace('coffee', 'js')] = filepath
        grunt.config ['coffee', 'static', 'files'], files
                      
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-shell')

    grunt.registerTask "dist", ["coffee", "shell:version"]
    grunt.registerTask "default", ["coffee", "shell:restart", "watch:scripts"]

