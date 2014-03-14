module.exports = (grunt) ->
  
    # Project configuration.
    grunt.initConfig
        buildVersion:'<%= pkg.version %>-'+grunt.template.today("yyyymmddHHmmss")
        pkg: grunt.file.readJSON("package.json")
        coffee :
            static:
                files :
                    'public/js/main.js':'public/js/main.coffee'
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
                    
        stylus:
            compile:
                files:
                    'public/css/main.css':['public/css/main.styl']
            
        watch:
            scripts:
                files: ['routes/*.coffee','*.coffee','public/js/*.coffee']
                tasks: ['coffee:static']
                options:
                    nospawn:true
            css:
                files: ['public/css/main.styl']
                tasks: ['stylus']
                options:
                    nospawn:true
                    
        nodemon:
            app :
                script: 'app.js'
                options:
                    ignored: ['public/js/**','Gruntfile.coffee','views/**']

        concurrent:
            target:
                tasks: ['watch:scripts','watch:css','nodemon:app']
                options:
                    logConcurrentOutput: true
                    
        shell:
            npm_install:
                command: 'npm install'
                options:
                    stdout:true
                    stderr:true
            npm_update:
                command: 'npm update'
                options:
                    stdout:true
        uglify:
            target:
                files:
                    'public/js/main.min.js' : 'public/js/main.js'
            options:
                compress:
                    warnings: true
                    

    grunt.event.on 'watch', (action, filepath) ->
        grunt.config ['buildVersion'],'<%= pkg.version %>-'+grunt.template.today("yyyymmddHHmmss")
        k=filepath.replace('coffee','js')
        files = [{}]
        files[0][filepath.replace('coffee','js')]=filepath
        grunt.config ['coffee','static','files'], files
                      
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-nodemon');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-contrib-stylus');

    grunt.registerTask "default", ["coffee","stylus","concurrent:target"]

