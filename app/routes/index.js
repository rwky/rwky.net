// vim: set ts=2 sw=2:
module.exports = (app) => {
  require('./pay.js')(app)
  require('./ecf.js')(app)

  app.get('/', (req, res) => {
    res.render('index')
  })
  app.get('/tos', (req, res) => {
    res.render('tos')
  })
  app.get('/privacy', (req, res) => {
    res.render('privacy')
  })
  app.get('/ip', (req, res) => {
    res.send(req.ip)
  })
}
