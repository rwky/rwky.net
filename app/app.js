// vim: set ts=2 sw=2:
const http = require('http')
const path = require('path')
const express = require('express')
const routes = require('./routes')
const nunjucks = require('nunjucks')
const app = express()
const config = require('./config/config')

app.enable('trust proxy')

app.set('views', path.join(__dirname, '/views'))

nunjucks.configure('views', {
  autoescape: true,
  express: app
})

app.set('view engine', 'html')
app.use(require('body-parser').urlencoded({
  extended: false
}))

app.use(require('body-parser').json())

app.use(require('body-parser').raw({
  type: '*/*'
}))

app.use((req, res, next) => {
  res.locals.version = require('./version')
  res.locals.paypal = config.paypal
  return next()
})

routes(app)

app.use((err, req, res, next) => {
  console.error(err + ' ' + err.stack)
  return res.status(500).send('Oops something has gone wrong, please try again')
})

http.createServer(app).listen(3000)
