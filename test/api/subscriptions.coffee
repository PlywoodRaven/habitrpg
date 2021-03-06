'use strict'

payments = require("../../website/src/controllers/payments")
app = require("../../website/src/server")

describe "Subscriptions", ->

  before (done) ->
    registerNewUser(done, true)

  it "Handles unsubscription", (done) ->
    cron = ->
      user.lastCron = moment().subtract(1, "d")
      user.fns.cron()

    expect(user.purchased.plan.customerId).to.not.be.ok()
    payments.createSubscription
      user: user
      customerId: "123"
      paymentMethod: "Stripe"
      sub: {key: 'basic_6mo'}

    expect(user.purchased.plan.customerId).to.be.ok()
    shared.wrap user
    cron()
    expect(user.purchased.plan.customerId).to.be.ok()
    payments.cancelSubscription user: user
    cron()
    expect(user.purchased.plan.customerId).to.be.ok()
    expect(user.purchased.plan.dateTerminated).to.be.ok()
    user.purchased.plan.dateTerminated = moment().subtract(2, "d")
    cron()
    expect(user.purchased.plan.customerId).to.not.be.ok()
    payments.createSubscription
      user: user
      customerId: "123"
      paymentMethod: "Stripe"
      sub: {key: 'basic_6mo'}

    expect(user.purchased.plan.dateTerminated).to.not.be.ok()
    done()
