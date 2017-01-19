$( ->
    $('.nav li').removeClass('active')
    $('.nav a[href="' + window.location.pathname + '"]').parent().addClass 'active'

    $('#stripe-form button').attr 'data-value', $('#stripe-form button').html()

    stripe = StripeCheckout.configure {
        key: 'pk_live_iTNSQnZ1HnNMLzrx2oG3UIBc'
        name: 'rwky.net'
        address: false
        panelLabel: 'Checkout',
        currency: $('#stripe-form input[name="currency"]').val()
        token: (res) ->
            $('#stripe-form').append($('<input type="hidden" name="stripeToken">')
            .val(res.id)).submit()
        closed: ->
            $('#stripe-form button').prop('disabled', false)
            .html($('#stripe-form button').attr('data-value'))
    }
    
    $('body.pay-online #stripe-form').on 'submit', ->
        $('#stripe-form button').prop('disabled', true).html('Processing..')
        if $(@).find('input[name="stripeToken"]').length is 0
            stripe.open({
                amount: $('#stripe-form input[name="amount"]').val() * 100
                description: 'Invoice ' + $('#stripe-form input[name="invoice"]').val()
            })
            false

    $('body.save-card #stripe-form').on 'submit', ->
        $('#stripe-form button').prop('disabled', true).html('Processing..')
        if $(@).find('input[name="stripeToken"]').length is 0
            stripe.open({
                email: $('#stripe-form input[type=email]').val()
                amount: '100'
                description: 'Saved card authorization'
            })
            false

)
