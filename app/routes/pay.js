// vim: set ts=2 sw=2:
const config = require('../config/config')
const stripe = require('stripe')(config.stripe)

module.exports = (app) => {
  app.get('/pay-online', (req, res) => {
    let currency, currencySym, stripeSuccess
    const amount = req.query.amount || 0
    const invoice = req.query.invoice || 'Invoice'
    const email = req.query.email || ''
    if (req.query.currency === 'USD') {
      currency = 'USD'
      currencySym = '$'
    } else if (req.query.currency === 'EUR') {
      currency = 'EUR'
      currencySym = '&euro;'
    } else {
      currency = 'GBP'
      currencySym = '&pound;'
    }
    if (req.query.success) {
      if (req.query.success === 'true') {
        stripeSuccess = '<div class="alert alert-success"> Payment received, thank you!</div>'
      } else {
        stripeSuccess = '<div class="alert alert-danger"> Payment failed, please try again!</div>'
      }
    }
    return res.render('pay-online', {
      amount: amount,
      invoice: invoice,
      email: email,
      currency: currency,
      currencySym: currencySym,
      showPaypal: currency === 'GBP' && req.query.paypal,
      stripe: true,
      stripeSuccess: stripeSuccess
    })
  })

  app.post('/pay-online/stripe', (req, res) => {
    let currency
    if (req.body.currency === 'USD') {
      currency = 'USD'
    } else if (req.body.currency === 'EUR') {
      currency = 'EUR'
    } else {
      currency = 'GBP'
    }

    const ops = {
      success_url: config.stripe_success,
      cancel_url: config.stripe_cancel,
      payment_method_types: ['card'],
      customer_email: req.body.email,
      line_items: [
        {
          amount: parseFloat(req.body.amount) * 100,
          currency: currency.toLowerCase(),
          description: req.body.invoice,
          name: req.body.invoice,
          quantity: 1
        }
      ]
    }

    stripe.checkout.sessions.create(ops, (err, session) => {
      if (err) {
        console.error(err)
      }
      return res.render('pay-online', {
        stripeSession: session ? session.id : null,
        stripePk: config.stripe_pk,
        stripe: true,
        stripeErr: err,
        email: req.body.email,
        amount: req.body.amount,
        currency: req.body.currency,
        invoice: req.body.invoice
      })
    })
  })
}
