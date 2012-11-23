Testing = require '../_helper.js'
should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert

# Models
Mailbox = require(__dirname+'/../../models/models').Mailbox

describe 'Mailbox', ->

  before (done) ->
    Testing.resetAllDatabases ->
      done()

  it 'should retrive some attributes', ->
    mailbox = new Mailbox
      name:        '[Gmail]'
      uidValidity: 123456789
      selectable:  false
      total:     3000
      unread:    20
    expect(mailbox.name).to.equal '[Gmail]'
    expect(mailbox.uidValidity).to.equal 123456789
    expect(mailbox.selectable).to.equal false
    expect(mailbox.total).to.equal 3000
    expect(mailbox.unread).to.equal 20

  it 'should be selectable by default', ->
    mailbox = new Mailbox
      name: '[Gmail]'
    expect(mailbox.selectable).to.equal true

  it 'should set the messages attributes to 0 by default', ->
    mailbox = new Mailbox
      name: '[Gmail]'
    expect(mailbox.total).to.equal 0
    expect(mailbox.unread).to.equal 0

  it 'should save the mailbox into database', (done) ->
    inbox = new Mailbox
      name:        'INBOX'
      uidValidity: 123456789
      total:     3000
      unread:    20
    inbox.save (err) ->
      throw err if err
      expect(inbox.id).to.not.equal undefined
      done()

  it 'should load a mailbox from the database', (done) ->
    Mailbox.find {where: {name: 'INBOX'}}, (err, results) ->
      throw err if err
      mailbox = results[results.length-1]
      expect(mailbox.name).to.equal 'INBOX'
      done()

   it 'should make a mailbox with a parent mailbox', (done) ->
    mailboxParent = new Mailbox
      name:        'Parent Mailbox'
      uidValidity: 123456789
      selectable:  false
    mailboxChild = new Mailbox
      name:        'Child Mailbox'
      uidValidity: 1234567890
    mailboxChild.setMailbox mailboxParent, ->
      expect(mailboxChild.mailbox.name).to.equal 'Parent Mailbox'
      done()
