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
    app.use express.logger("dev")
else
    app.use express.logger()
app.use express.urlencoded()
app.use require('cookie-session')(keys:[app.config.session],secureProxy:true)
app.use express.csrf()
app.use express.static(path.join(__dirname, "public"))
app.use (req,res,next)->
    res.locals.csrf = req.csrfToken()
    res.locals.paypal = app.config.paypal
    next()
app.use app.router
routes app

# development only
app.use express.errorHandler()  if "development" is app.get("env")

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
