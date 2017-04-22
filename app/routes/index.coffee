module.exports = (app) ->
    mailer = require('nodemailer')
    .createTransport require('nodemailer-smtp-transport')(app.config.smtp)
    stripe = require('stripe')(app.config.stripe)
    async = require 'async'
    request = require 'request'
    
    app.get '/', (req, res) ->
        res.render 'index', bodyClass: 'index'
    
    app.get '/tos', (req, res) ->
        res.render 'tos', bodyClass: 'tos'
            
    app.get '/privacy', (req, res) ->
        res.render 'privacy', bodyClass: 'privacy'
    
    app.get '/save-card', (req, res) ->
        name = req.query.name or ''
        email = req.query.email or ''
        res.render 'save-card', bodyClass: 'save-card', name: name, email: email

    app.post '/save-card', (req, res) ->
        email = req.body.email
        name = req.body.name
        async.waterfall [
            (c) ->
                unless email? and name? and email and name
                    return c 'You must enter your name and email'
                c()
            (c) ->
                ops =
                    email: req.body.email
                    description: req.body.name
                    card: req.body.stripeToken
                stripe.customers.create ops, (err, customer) ->
                    if err? then return c 'Unable to save card details, please try again (Error:1)'
                    c null, customer
            (customer, c) ->
                ops =
                    customer: customer.id
                    source: customer.sources.data[0].id
                    amount: '100'
                    capture: false
                    currency: 'gbp'
                stripe.charges.create  ops, (err, charge) ->
                    if err?
                        if err.name is 'card_error'
                            return c err.message
                        ops =
                            from: app.config.from_email
                            to: app.config.to_email
                            subject: 'rwky.net payment error'
                            text: 'Payment error: ' + err.name + ' ' +
                            err.message + ' for card authorization'
                        mailer.sendMail ops
                        return c 'Unable to save card details, please try again (Error:2)'
                    c null, charge
            (charge, c) ->
                stripe.charges.createRefund charge.id,
                { metadata: { auth_cancellation: 1} }, (err) ->
                    if err?
                        ops =
                            from: app.config.from_email
                            to: app.config.to_email
                            subject: 'rwky.net payment error'
                            text: 'Payment error: ' + err.name + ' ' +
                            err.message + ' for card authorization'
                        mailer.sendMail ops
                    else
                        ops =
                            from: app.config.from_email
                            to: app.config.to_email
                            subject: 'rwky.net customer created'
                            text: 'Customer created for ' + req.body.email + ' ' + req.body.name
                        mailer.sendMail ops
                    c()
        ], (err) ->
            unless err then msg = 'Card details saved!'
            res.render 'save-card', bodyClass: 'save-card', err: err, msg: msg

    app.get '/pay-online', (req, res) ->
        amount = req.query.amount or 0
        invoice = req.query.invoice or ''
        if req.query.currency is 'USD'
            currency = 'USD'
            currencySym = '$'
        else if req.query.currency is 'EUR'
            currency = 'EUR'
            currencySym = '&euro;'
        else
            currency = 'GBP'
            currencySym = '&pound;'

        res.render 'pay-online', {
            bodyClass: 'pay-online'
            amount: amount
            invoice: invoice
            currency: currency
            currencySym: currencySym
            show_paypal: currency is 'GBP'
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
            currency: currency
            amount: parseFloat(req.body.amount) * 100
            source: req.body.stripeToken
            description: req.body.invoice
        stripe.charges.create ops, (err, r) ->
            if err?
                if err.name is 'card_error'
                    errmsg = err.message
                else
                    ops =
                        from: app.config.from_email
                        to: app.config.to_email
                        subject: 'rwky.net payment error'
                        text: 'Payment error: ' + err.name + ' ' + err.message +
                        ' for invoice ' + req.body.invoice + ' with amount ' + req.body.amount
                    mailer.sendMail ops
                    errmsg = 'Unable to process transaction, please try again'
            else
                msg = 'Transaction processed successfully. Thank you!'
            res.render 'pay-online', {
                bodyClass: 'pay-online'
                err: errmsg
                msg: msg
                amount: req.body.amount
                invoice: req.body.invoice
                currency: currency
                currencySym: currencySym
                show_paypal: currency is 'GBP'
            }
            

    app.get '/ip', (req, res) ->
        res.send req.ip

    app.all '/ecf/:id', (req, res, next) ->
        req.contact = app.config.contacts.filter((v) -> v.id is req.params.id)[0]
        unless req.contact then return res.status(403).send 'Access denied'
        next()
    
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
                request.post app.config.sms_url, { json: true, headers: { "x-api-key": app.config.sms_api_key }, body: { msg: msg.slice(0,100) } }, (err, httpResponse, body) ->
                    if err then return c err
                    unless body.status is 'queued' then return c body
                    c()
            retry (c) ->
                request.post app.config.slack_url, { json: true, body: { text: msg } }, (err, httpResponse, body) ->
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

    app.get '/essentials', (req, res) ->
        res.render 'essentials', bodyClass: 'essentials'

    app.post '/essentials', (req, res) ->
        ops =
            from: app.config.from_email
            to: app.config.to_email
            subject: 'Essentials server request'
            text: JSON.stringify(req.body)
        contact_msg =
            msg: "Since I like to add a personal touch to my services, I'll email you as soon as possible to confirm your request"
            alert: 'success'
        mailer.sendMail ops, (err) ->
            if err?
                contact_msg =
                    msg: 'There was an error sending your request, please try again'
                    alert: 'danger'
            res.render 'essentials', bodyClass: 'essentials', contact_msg: contact_msg
