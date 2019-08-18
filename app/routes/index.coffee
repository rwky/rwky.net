module.exports = (app) ->
    mailer = require('nodemailer')
    .createTransport require('nodemailer-smtp-transport')(app.config.smtp)
    stripe = require('stripe')(app.config.stripe)
    async = require 'async'
    request = require 'request'

    ping = (msg, cb) ->
        request.post app.config.slack_url, { json: true, body: { text: msg } }, cb
    
    app.get '/', (req, res) ->
        res.render 'index', bodyClass: 'index'
    
    app.get '/tos', (req, res) ->
        res.render 'tos', bodyClass: 'tos'
            
    app.get '/privacy', (req, res) ->
        res.render 'privacy', bodyClass: 'privacy'
    
    app.get '/pay-online', (req, res) ->
        amount = req.query.amount or 0
        invoice = req.query.invoice or 'Invoice'
        email = req.query.email or ''
        if req.query.currency is 'USD'
            currency = 'USD'
            currencySym = '$'
        else if req.query.currency is 'EUR'
            currency = 'EUR'
            currencySym = '&euro;'
        else
            currency = 'GBP'
            currencySym = '&pound;'

        if req.query.success?
            if req.query.success is 'true'
                stripeSuccess = '<div class="alert alert-success">
                Payment received, thank you!</div>'
            else
                stripeSuccess = '<div class="alert alert-danger">
                Payment failed, please try again!</div>'
        
        res.render 'pay-online', {
            bodyClass: 'pay-online'
            amount: amount
            invoice: invoice
            email: email
            currency: currency
            currencySym: currencySym
            showPaypal: currency is 'GBP' and req.query.paypal?
            stripe: true
            stripeSuccess: stripeSuccess
        }
    
    app.post '/pay-online/stripe', (req, res) ->
        if req.body.currency is 'USD'
            currency = 'USD'
            currencySym = '$'
        else if req.body.currency is 'EUR'
            currency = 'EUR'
            currencySym = '&euro;'
        else
            currency = 'GBP'
            currencySym = '&pound;'

        ops =
            success_url: app.config.stripe_success
            cancel_url: app.config.stripe_cancel
            payment_method_types: ['card']
            customer_email: req.body.email
            line_items: [{
                amount: parseFloat(req.body.amount) * 100
                currency: currency.toLowerCase()
                description: req.body.invoice
                name: req.body.invoice
                quantity: 1
            }]

        stripe.checkout.sessions.create ops, (err, session) ->
            if err? then console.error err
            res.render 'pay-online', {
                bodyClass: 'pay-online'
                stripeSession: session?.id
                stripePk: app.config.stripe_pk
                stripe: true
                stripeErr: err?
                email: req.body.email
                amount: req.body.amount
                currency: req.body.currency
                invoice: req.body.invoice
            }
            

    app.get '/ip', (req, res) ->
        res.send req.ip

    app.all '/ecf/:id', (req, res, next) ->
        req.contact = app.config.contacts.filter((v) -> v.id is req.params.id)[0]
        unless req.contact then return res.status(403).send 'Access denied'
        next()
    
    app.post '/ping/' + app.config.ping_token, (req, res, next) ->
        msg = if req.body.text? then req.body.text else req.body.attachments?[0]?.text
        ping msg, (err, httpResponse, body) ->
            if err or body isnt 'ok'
                console.error err
                console.error body
                return res.status(500).send('failed')
            res.send('ok')

    app.get '/ecf/:id', (req, res) ->
        res.render 'ecf'

    app.post '/ecf/:id', (req, res) ->
        retry_ops =
            times: 3
            interval: 1000
            errorFilter: (err) ->
                console.error err
                true
        
        msg = "From: " + req.contact.email + " "
    
        if Buffer.isBuffer(req.body)
            msg += req.body.toString('utf8')
        else if req.body.message
            msg += req.body.message
        else
            try
                msg += JSON.stringify(req.body)
            catch e
                msg += req.body.toString()

        retry = (f) ->
            async.retry retry_ops, f
            
        if req.path.indexOf('debug') is -1
            retry (c) ->
                ops = {
                    json: true,
                    headers: { "x-api-key": app.config.sms_api_key },
                    body: { msg: msg.slice(0, 100) }
                }
                request.post app.config.sms_url, ops, (err, httpResponse, body) ->
                    if err then return c err
                    unless body.status is 'queued' then return c body
                    c()
            retry (c) ->
                ping msg, (err, httpResponse, body) ->
                    if err then return c err
                    unless body is 'ok' then return c body
                    c()
        retry (c) ->
            ops =
                from: app.config.from_email
                replyTo: req.contact.email
                to: app.config.ecf_email
                subject: 'Emergency contact form'
                text: msg
            mailer.sendMail ops, (err) ->
                if err then return c err
                c()
        res.render 'ecf', { msg: 'Message sent' }
