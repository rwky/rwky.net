stripeSession = document.getElementById('stripe-session')
if stripeSession
    stripe = Stripe(stripeSession.getAttribute('data-pk'))
    stripe.redirectToCheckout {
        sessionId: stripeSession.value
    }
