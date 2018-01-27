    stripeForm = document.getElementById('stripe-form')
    stripe = StripeCheckout.configure {
        key: 'pk_live_iTNSQnZ1HnNMLzrx2oG3UIBc'
        name: 'rwky.net'
        panelLabel: 'Checkout',
        zipCode: true
        token: (res) ->
            tokenEl = document.createElement('input')
            tokenEl.setAttribute('type', 'hidden')
            tokenEl.setAttribute('value', res.id)
            tokenEl.setAttribute('name', 'stripeToken')
            tokenEl.setAttribute('id', 'stripe-token')
            stripeForm.appendChild(tokenEl)
            stripeForm.submit()
    }
    
    if stripeForm
        stripeForm.onsubmit = ->
            unless document.getElementById('stripe-token')
                stripe.open({
                    amount: document.getElementById("stripe-amount").value * 100
                    email: document.getElementById('stripe-email').value
                    currency: document.getElementById('stripe-currency').value
                    description: 'Invoice ' + document.getElementById("stripe-invoice").value
                })
                false
