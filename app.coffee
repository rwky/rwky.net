express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()
routes = require './routes'
app.config = require './config'

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "hjs"
if "development" is app.get("env")
    app.use require('morgan')('dev')
else
    app.use require('morgan')('combined')
app.use require('cookie-parser')()
app.use require('body-parser').urlencoded(extended:false)
app.use require('csurf')(cookie:{key:'csrf'})
app.use express.static(path.join(__dirname, "public"))
app.use (req,res,next)->
    res.locals.csrf = req.csrfToken()
    res.locals.paypal = app.config.paypal
    res.locals.noclients = app.config.noclients
    next()
routes app

app.use (err,req,res,next)->
    if err.message isnt 'invalid csrf token'
       console.error err+' '+err.stack
       return res.status(500).send('Oops something has gone wrong, please try again')
    res.status(403).send('There is a problem with your session, please try clearing your cookies and trying your request again')

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
