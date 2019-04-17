stripeSession = document.getElementById('stripe-session')
console.log stripeSession
if stripeSession
    stripe = Stripe(stripeSession.getAttribute('data-pk'))
    stripe.redirectToCheckout {
        sessionId: stripeSession.value
    }
