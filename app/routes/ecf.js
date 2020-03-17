// vim: set ts=2 sw=2:
const https = require('https')
const config = require('../config/config')
const mailer = require('nodemailer').createTransport(require('nodemailer-smtp-transport')(config.smtp))

function httpsRequest (url, headers, body) {
  return new Promise((resolve, reject) => {
    let data = ''
    const ops = {
      method: 'POST',
      headers: headers
    }

    ops.headers['Content-Type'] = 'application/json'
    const req = https.request(url, ops, (res) => {
      res.on('data', (chunk) => {
        data += chunk
      })
      res.on('end', () => {
        resolve(data)
      })
    })
    req.on('err', (err) => {
      reject(err)
    })
    req.write(JSON.stringify(body))
    req.end()
  })
}

async function sms (msg) {
  const headers = {
    'x-api-key': config.sms_api_key
  }
  msg = msg.slice(0, 100)
  const res = JSON.parse(await httpsRequest(config.sms_url, headers, { msg: msg }))
  if (res.status !== 'queued') {
    throw new Error('Invalid response from SMS: ' + JSON.stringify(res))
  }
  return res
}

async function ping (msg) {
  const res = await httpsRequest(config.slack_url, {}, { text: msg })
  if (res !== 'ok') {
    throw new Error('Invalid response from slack ' + res)
  }
  return res
}

async function mail (msg) {
  const ops = {
    from: config.from_email,
    to: config.ecf_email,
    subject: 'Emergency contact form',
    text: msg
  }
  return mailer.sendMail(ops)
}

module.exports = (app) => {
  app.all('/ecf/:id', (req, res, next) => {
    req.contact = config.contacts.filter((v) => {
      return v.id === req.params.id
    })[0]
    if (!req.contact) {
      return res.status(403).send('Access denied')
    }
    next()
  })

  app.post('/ping/' + config.ping_token, async (req, res, next) => {
    let msg
    if (req.body.payload) {
      msg = JSON.parse(req.body.payload).text
    } else if (req.body.text !== undefined) {
      msg = req.body.text
    } else {
      msg = req.body.attachments[0].text
    }
    try {
      const body = await ping(msg)
      if (body !== 'ok') {
        return res.status(500).send('failed')
      }
      res.send('ok')
    } catch (e) {
      console.error(e)
      res.status(500).send('failed')
    }
  })

  app.get('/ecf/:id', (req, res) => {
    return res.render('ecf')
  })

  app.post('/ecf/:id', async (req, res) => {
    let msg = 'From: ' + req.contact.email + ' '
    if (Buffer.isBuffer(req.body)) {
      msg += req.body.toString('utf8')
    } else if (req.body.message) {
      msg += req.body.message
    } else {
      try {
        msg += JSON.stringify(req.body)
      } catch (e) {
        msg += req.body.toString()
      }
    }
    let failed = false
    if (req.path.indexOf('debug') === -1) {
      // send sms
      try {
        await sms(msg)
      } catch (e) {
        console.error(e)
        failed = true
      }
      // send ping
      try {
        await ping(msg)
      } catch (e) {
        console.error(e)
        failed = true
      }
    }
    // send email
    try {
      await mail(msg)
    } catch (e) {
      console.error(e)
      failed = true
    }
    return res.render('ecf', {
      failed: failed
    })
  })
}
