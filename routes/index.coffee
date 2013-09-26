module.exports = (app) ->
    mailer = require('nodemailer').createTransport('Sendmail','/usr/sbin/sendmail')    
    stripe = require('stripe')(app.config.stripe)
    
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
    
    app.get '/pay-online',(req,res)->
        amount = req.query.amount || 0
        invoice = req.query.invoice || ''
        res.render 'pay-online',bodyClass:'pay-online',amount:amount,invoice:invoice,partials:
            'header':'header.hjs','footer':'footer.hjs'
    
    app.post '/pay-online/stripe',(req,res)->
        ops =
            currency:'gbp'
            amount:req.body.amount*100
            card:req.body.stripeToken
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
                ops =
                        from:app.config.from_email
                        to:app.config.to_email
                        subject:'rwky.net payment'
                        text:'Invoice: '+req.body.invoice+' paid with amount '+(r.amount/100)
                    mailer.sendMail ops
            res.render 'pay-online',bodyClass:'pay-online',err:errmsg,msg:msg,partials:
                'header':'header.hjs','footer':'footer.hjs'
    
    app.get '/contact',(req,res)->
        res.render 'contact',bodyClass:'contact',partials:
            'header':'header.hjs','footer':'footer.hjs'
            
    app.post '/contact',(req,res)->
        ops =
            from:app.config.from_email
            to:app.config.to_email
            subject:'rwky.net contact form'
            text:'A message from '+req.body.email+"\r\n"+req.body.message
        mailer.sendMail ops,(err)->
            if err?
                err='There was an error sending your mail, please try again'
            else
                msg='Email sent, you should receive a reply within 24 hours Monday to Friday.'
            res.render 'contact',bodyClass:'contact',msg:msg,err:err,partials:
                'header':'header.hjs','footer':'footer.hjs'
            
    
