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
                    
        stylus:
            compile:
                files:
                    'public/css/main.css': ['public/css/main.styl']
            
        watch:
            scripts:
                files: ['routes/*.coffee', '*.coffee', 'public/js/*.coffee']
                tasks: ['coffee:static', 'shell:restart']
                options:
                    nospawn: true
            css:
                files: ['public/css/main.styl']
                tasks: ['stylus']
                options:
                    nospawn: true
                    
        concurrent:
            target:
                tasks: ['watch:scripts', 'watch:css']
                options:
                    logConcurrentOutput: true
                    
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
                    stderr: true
        uglify:
            target:
                files:
                    'public/js/main.min.js': 'public/js/main.js'
            options:
                compress:
                    warnings: true
                    

    grunt.event.on 'watch', (action, filepath) ->
        files = [{}]
        files[0][filepath.replace('coffee', 'js')] = filepath
        grunt.config ['coffee', 'static', 'files'], files
                      
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-concurrent')
    grunt.loadNpmTasks('grunt-contrib-stylus')
    grunt.loadNpmTasks('grunt-shell')

    grunt.registerTask "dist", ["coffee", "stylus", "uglify"]
    grunt.registerTask "default", ["coffee", "stylus", "shell:restart", "concurrent:target"]

