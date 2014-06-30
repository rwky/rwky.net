$(->
    $('.nav li').removeClass('active')
    $('.nav a[href="'+window.location.pathname+'"]').parent().addClass 'active'
    
    $('#stripe-form').on 'submit',()->
        $('#stripe-form button').prop('disabled',true).html('Processing..')
        if $(@).find('input[name="stripeToken"]').length is 0
            StripeCheckout.open({
              key:         'pk_live_iTNSQnZ1HnNMLzrx2oG3UIBc',
              address:     false,
              amount:      $('#stripe-form input[name="amount"]').val()*100,
              currency:    'gbp',
              name:        'Invoice '+$('#stripe-form input[name="invoice"]').val(),
              panelLabel:  'Checkout',
              token:       (res)->
                              $('#stripe-form').append($('<input type="hidden" name="stripeToken">').val(res.id)).submit();
            });
            false

)
