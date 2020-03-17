// vim: set ts=2 sw=2:
/* global Stripe */
const stripeSession = document.getElementById('stripe-session')

if (stripeSession) {
  const stripe = Stripe(stripeSession.getAttribute('data-pk'))
  stripe.redirectToCheckout({
    sessionId: stripeSession.value
  })
}
