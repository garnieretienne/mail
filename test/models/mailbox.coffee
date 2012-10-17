Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
Mailbox = require '../../models/mailbox'

describe 'Mailbox', ->

  it 'should retrive some attributes', ->
    mailbox = new Mailbox
      name:        '[Gmail]'
      uidvalidity: 123456789
      selectable:  false
      hasChilds:   true
      hasParent:   false
      messages:
        total:     3000
        unread:    20
    expect(mailbox.name).to.equal '[Gmail]'
    expect(mailbox.uidvalidity).to.equal 123456789
    expect(mailbox.selectable).to.equal false
    expect(mailbox.hasChilds).to.equal true
    expect(mailbox.hasParent).to.equal false
    expect(mailbox.messages.total).to.equal 3000
    expect(mailbox.messages.unread).to.equal 20

  it 'should be selectable by default', ->
    mailbox = new Mailbox
      name: '[Gmail]'
    expect(mailbox.selectable).to.equal true

  it 'should not have childs or parent by default', ->
    mailbox = new Mailbox
      name: '[Gmail]'
    expect(mailbox.hasChilds).to.equal false
    expect(mailbox.hasParent).to.equal false

  it 'should set the messages attributes to 0 by default', ->
    mailbox = new Mailbox
      name: '[Gmail]'
    expect(mailbox.messages.total).to.equal 0
    expect(mailbox.messages.unread).to.equal 0

