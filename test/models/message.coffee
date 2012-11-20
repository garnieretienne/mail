Testing = require '../_helper.js'
should  = require('chai').should()
expect  = require('chai').expect
assert  = require('chai').assert

Models  = require(__dirname+'/../../models/models')
Message = Models.Message
Mailbox = Models.Mailbox
Account = Models.Account

describe 'Message', ->

  before (done) ->
    _this = @
    Testing.resetAllDatabases ->
      _this.loremIpsum = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
      _this.attr = 
        seqno: 1111
        uid: 111
        subject: 'Testing Email',
        from: {
          name: 'Etienne Garnier',
          address: 'etienne.garnier@domain.tld'
        },
        to: ['me@domain.tld', 'another.person@domain.tld'],
        date: 'Mon, 17 Sep 2012 09:16:06 GMT',
        body: {
          text: _this.loremIpsum,
          html: "<p>#{_this.loremIpsum}</p>"
        }
        flags: ['Seen']
      account = new Account
        username: Testing.imapSettings.username
        password: Testing.imapSettings.password
      _this.mailbox = new Mailbox
        name: 'INBOX'
      _this.mailbox.setAccount account, ->
        _this.mailbox.save (err) ->
          throw err if err
          done()

  it 'should create a new message and retrieve its attributes', ->
    message = new Message(@attr)
    expect(message.subject).to.equal 'Testing Email'
  
  it 'should create the md5 hash for the "from" address field if not given in contructor', ->
    message = new Message this.attr
    expect(message.from.md5).to.equal '2722df622f5925b4307a07208fb801ca'

  it 'should create the sample from the text if not given in contructor', ->
    message = new Message this.attr
    expect(message.sample).to.equal 'Lorem ipsum dolor sit amet, consectetur adipisicin...'

  it 'should import a raw message containing headers and structure (ImapMessage) and create a new Message object from it', ->
    imapMessage = { 
      seqno: 10,
      headers: { 
        'delivered-to': [ 'webmail.testing.dev@gmail.com' ],
        received: [ 
          'by 10.114.57.180 with SMTP id j20csp135862ldq; Mon, 8 Oct 2012 06:08:40 -0700 (PDT)',
          'by 10.112.43.137 with SMTP id w9mr6630017lbl.134.1349701720540; Mon, 08 Oct 2012 06:08:40 -0700 (PDT)',
          'from nj2mta2.uswhwk6.savvis.net (inet.uswhwk6.savvis.net. [64.15.252.10]) by mx.google.com with ESMTP id f2si10559245lbi.23.2012.10.08.06.08.40; Mon, 08 Oct 2012 06:08:40 -0700 (PDT)',
          'from mail-01nj2x.reutersmedia.net (unknown [10.33.124.10]) by nj2mta2.uswhwk6.savvis.net (Postfix) with ESMTP id CE0E22F6B for <webmail.testing.dev@gmail.com>; Mon,  8 Oct 2012 13:08:39 +0000 (UTC)',
          'from S264630NJ2XCM07.g3.reuters.com ([10.33.140.109]) by mail-01nj2x.reutersmedia.net (8.13.8/8.13.8) with SMTP id q98D8Y3T006096 for <webmail.testing.dev@gmail.com>; Mon, 8 Oct 2012 13:08:34 GMT',
          'from S264630NJ2XCM07 (localhost.localdomain [127.0.0.1]) by S264630NJ2XCM07.g3.reuters.com (8.13.8/8.13.8) with ESMTP id q98D8Yxr015531 for <webmail.testing.dev@gmail.com>; Mon, 8 Oct 2012 13:08:34 GMT' 
        ],
        'return-path': [ '<ecommerce@reuters.com>' ],
        'received-spf': [ 'neutral (google.com: 64.15.252.10 is neither permitted nor denied by best guess record for domain of ecommerce@reuters.com) client-ip=64.15.252.10;' ],
        'authentication-results': [ 'mx.google.com; spf=neutral (google.com: 64.15.252.10 is neither permitted nor denied by best guess record for domain of ecommerce@reuters.com) smtp.mail=ecommerce@reuters.com' ],
        date: [ 'Mon, 8 Oct 2012 13:08:34 +0000 (UTC)' ],
        from: [ 'Reuters.com <ecommerce@reuters.com>' ],
        to: [ 'webmail.testing.dev@gmail.com' ],
        'message-id': [ '<677692338.260391349701714451.JavaMail.tomcat@S264630NJ2XCM07>' ],
        subject: [ 'Welcome to Reuters.com' ],
        'mime-version': [ '1.0' ],
        'content-type': [ 'text/html; charset=us-ascii' ],
        'content-transfer-encoding': [ '7bit' ],
        'x-mailer': [ 'Reuters.com e-commerce Mailer' ] },
      uid: 10,
      flags: ['\\Seen'],
      date: '08-Oct-2012 15:54:41 +0200',
      structure: [ 
        { 
          partID: '1',
          type: 'text',
          subtype: 'html',
          params: [Object],
          id: null,
          description: null,
          encoding: '7bit',
          size: 2713,
          lines: 44,
          md5: null,
          disposition: null,
          language: null,
          location: null 
        } 
      ] 
    }
    Message.fromImapMessage imapMessage, (message) ->
      expect(message.subject).to.equal 'Welcome to Reuters.com'
      expect(message.from.name).to.equal 'Reuters.com'
      expect(message.from.address).to.equal 'ecommerce@reuters.com'
      expect(message.to[0]).to.equal 'webmail.testing.dev@gmail.com'
      expect(message.seqno).to.equal 10
      expect(message.uid).to.equal 10
      expect(message.flags[0]).to.equal '\\Seen'
      expect(message.date).to.equal '08-Oct-2012 15:54:41 +0200'
      expect(message.from.md5).to.equal 'ef9766f56c62aac51acfeba434b8d766'
      expect(message.parts['text/plain']).to.equal undefined
      expect(message.parts['text/html']).to.equal '1'

  it 'should find mime type and associed partID from a ImapMessage structure', ->
    structure = [ 
      { 
        type: 'mixed'
      , params: { boundary: '000e0cd294e80dc84c0475bf339d' }
      , disposition: null
      , language: null
      , location: null
      }
    , [ 
        { 
          type: 'alternative'
        , params: { boundary: '000e0cd294e80dc83c0475bf339b' }
        , disposition: null
        , language: null
        }
      , [ 
          { 
            partID: '1.1'
          , type: 'text'
          , subtype: 'plain'
          , params: { charset: 'ISO-8859-1' }
          , id: null
          , description: null
          , encoding: '7BIT'
          , size: 935
          , lines: 46
          , md5: null
          , disposition: null
          , language: null
          }
        ]
      , [ 
          { 
            partID: '1.2'
          , type: 'text'
          , subtype: 'html'
          , params: { charset: 'ISO-8859-1' }
          , id: null
          , description: null
          , encoding: 'QUOTED-PRINTABLE'
          , size: 1962
          , lines: 33
          , md5: null
          , disposition: null
          , language: null
          }
        ]
      ]
    , [ 
        { 
          partID: '2'
        , type: 'application'
        , subtype: 'octet-stream'
        , params: { name: 'somefile' }
        , id: null
        , description: null
        , encoding: 'BASE64'
        , size: 98
        , lines: null
        , md5: null
        , disposition:
           { 
             type: 'attachment'
           , params: { filename: 'somefile' }
           }
        , language: null
        , location: null
        }
      ]
    ]
    mappedPartIDs = Message.mapPartIDs structure
    expect(mappedPartIDs['text/plain']).to.equal '1.1'
    expect(mappedPartIDs['text/html']).to.equal '1.2'

  it 'should save the message into database', (done) ->
    message = new Message @attr
    message.setMailbox @mailbox, ->
      message.save (err) ->
        throw err if err
        expect(message.id).to.not.equal undefined
        done()

  it 'should load a message from cache', (done) ->
    _this = @
    Message.find {uid: 111}, (err, results) ->
      throw err if err
      message = results[results.length-1]
      expect(message.uid).to.equal 111
      expect(message.subject).to.equal 'Testing Email'
      message.getMailbox (err, mailbox) ->
        throw err if err
        expect(mailbox.id).to.equal _this.mailbox.id
        done()