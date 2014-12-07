express = require("express")
routes = require("./routes")
http = require("http")
https = require("https")
path = require("path")
app = express()
routes = require './routes'
app.config = require './config/config'

# all environments
app.set "views", __dirname + "/views"
app.set "view engine", "hjs"
app.use require('cookie-parser')()
app.use require('body-parser').urlencoded(extended:false)
app.use require('csurf')(cookie:{key:'csrf',secure:process.env.NODE_ENV isnt 'dev',httpOnly:true})
app.use (req,res,next)->
    # add idle timeout handlers. this is when NO data is sent/recieved 
    res.setTimeout 180000,->
        res.status(408)
        next new Error('Client Timeout'),req,res
    req.setTimeout 180000,->
        res.status(504)
        next new Error('Gateway Timeout'),req,res
    
    # add general timeout, this prevents processes from lasting forever (or in the case of passenger 10 minutes)
    req.timeout = setTimeout ->
        res.status(504)
        next new Error('Request Timeout'),req,res
    ,180000
    res.oldEnd = res.end
    res.end = ->
        args = arguments
        clearTimeout req.timeout
        res.oldEnd.apply this,args
    res.locals.csrf = req.csrfToken()
    res.locals.paypal = app.config.paypal
    next()
routes app

app.use (err,req,res,next)->
    if err.message isnt 'invalid csrf token'
       console.error err+' '+err.stack
       return res.status(500).send('Oops something has gone wrong, please try again')
    res.status(403).send('There is a problem with your session, please try clearing your cookies and trying your request again')

http.createServer(app).listen 3000
