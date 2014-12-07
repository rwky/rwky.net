module.exports = (app) ->
    mailer = require('nodemailer').createTransport require('nodemailer-sendmail-transport')()  
    stripe = require('stripe')(app.config.stripe)
    async = require 'async'
    
    app.get '/',(req,res)->
        res.render 'index',bodyClass:'index',partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/server-administration',(req,res)->
        res.render 'server-administration',bodyClass:'server-administration',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.get '/programming',(req,res)->
        res.render 'programming',bodyClass:'programming',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.get '/testimonials',(req,res)->
        res.render 'testimonials',bodyClass:'testimonials',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.get '/open-source',(req,res)->
        res.render 'open-source',bodyClass:'open-source',partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/tos',(req,res)->
        res.render 'tos',bodyClass:'tos',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.get '/privacy',(req,res)->
        res.render 'privacy',bodyClass:'privacy',partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/affiliates',(req,res)->
        res.render 'affiliates',bodyClass:'affiliates',partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/save-card', (req, res) ->
        name = req.query.name or ''
        email = req.query.email or ''
        res.render 'save-card', bodyClass:'save-card', name:name, email:email, partials:
            'header':'header.hjs','footer':'footer.hjs'

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
                    card: customer.sources.data[0].id
                    amount: '100'
                    capture: false
                    currency: 'gbp'
                stripe.charges.create  ops, (err, charge) ->
                    if err?
                        if err.name is 'card_error'
                            return c err.message
                        ops =
                            from:app.config.from_email
                            to:app.config.to_email
                            subject:'rwky.net payment error'
                            text:'Payment error: '+err.name+' '+err.message+' for card authorization'
                        mailer.sendMail ops
                        return c 'Unable to save card details, please try again (Error:2)'
                    c null, charge
            (charge, c) ->
                stripe.charges.createRefund charge.id, { metadata: { auth_cancellation: 1} }, (err) ->
                    if err?
                        ops =
                            from:app.config.from_email
                            to:app.config.to_email
                            subject:'rwky.net payment error'
                            text:'Payment error: '+err.name+' '+err.message+' for card authorization'
                        mailer.sendMail ops
                    else
                        ops =
                            from:app.config.from_email
                            to:app.config.to_email
                            subject:'rwky.net customer created'
                            text: 'Customer created for '+req.body.email+' '+req.body.name
                        mailer.sendMail ops
                    c()
        ], (err) ->
            unless err then msg = 'Card details saved!'
            res.render 'save-card',bodyClass:'save-card',err:err,msg:msg,partials:
                    'header':'header.hjs','footer':'footer.hjs'

    app.get '/pay-online',(req,res)->
        amount = req.query.amount || 0
        invoice = req.query.invoice || ''
        res.render 'pay-online',bodyClass:'pay-online',amount:amount,invoice:invoice,partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.post '/pay-online/stripe',(req,res)->
        ops =
            currency:'gbp'
            amount:req.body.amount*100
            source:req.body.stripeToken
            description:req.body.invoice
        stripe.charges.create ops,(err,r)->
            if err?
                if err.name is 'card_error'
                    errmsg = err.message
                else
                    ops =
                        from:app.config.from_email
                        to:app.config.to_email
                        subject:'rwky.net payment error'
                        text:'Payment error: '+err.name+' '+err.message+' for invoice '+req.body.invoice+' with amount '+req.body.amount
                    mailer.sendMail ops
                    errmsg = 'Unable to process transaction, please try again'
            else
                msg='Transaction processed successfully. Thank you!'
            res.render 'pay-online',bodyClass:'pay-online',err:errmsg,msg:msg,partials:
                'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/contact',(req,res)->
        res.render 'contact',bodyClass:'contact',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.post '/contact',(req,res)->
        msg='Email sent, you should receive a reply within 24 hours Monday to Friday.'
        blockStrings = ['[/url]']
        blocked = blockStrings.filter((el)-> req.body.message.indexOf(el) isnt -1).length
        err=false
        render = ()->
            res.render 'contact',bodyClass:'contact',msg:msg,err:err,partials:
                'header':'header.hjs','footer':'footer.hjs'
        ops =
            from:app.config.from_email
            to:app.config.to_email
            subject:'rwky.net contact form'
            text:'A message from '+req.body.email+"\r\n"+req.body.message
        if req.body.name isnt '' or req.body.email is '' or req.body.message is '' or blocked
            render()
        else
            mailer.sendMail ops,(e)->
                if e?
                    err='There was an error sending your mail, please try again'
                    msg=false
                render()
            
            
    
