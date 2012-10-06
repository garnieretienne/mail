should  = require('chai').should()
expect = require('chai').expect
assert = require('chai').assert
Message = require '../../models/message'

describe 'Message', ->

  before ->
    this.loremIpsum = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    this.attr = 
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
        text: this.loremIpsum,
        html: "<p>#{this.loremIpsum}</p>"
      }
      flags: ['Seen'],


  it 'should create a new message and retrieve its attributes', ->
    attr = {
      seqno: 1,
      uid: 1,
      subject: 'Hello World',
      from: {
        name: 'Etienne Garnier',
        address: 'etienne.garnier@domain.tld',
        md5: "64fe483361c5f1b54973f27b8a0b4df5"
      },
      to: ['me@domain.tld', 'another.person@domain.tld'],
      date: 'Mon, 17 Sep 2012 09:16:06 GMT',
      sample: "Hello World",
      body: {
        text: "Hello World",
        html: "<h1>Hello World</h1>"
      }
      flags: ['Seen'],
    }
    message = new Message(attr)
    expect(message.subject).to.equal 'Hello World'
  
  it 'should create the md5 hash for the "from" address field if not given in contructor', ->
    message = new Message this.attr
    expect(message.from.md5).to.equal '2722df622f5925b4307a07208fb801ca'

  it 'should create the sample from the text if not given in contructor', ->
    message = new Message this.attr
    expect(message.sample).to.equal 'Lorem ipsum dolor sit amet, consectetur adipisicin...'

  it 'should import a parsed message (using mailparser) and create a new model from it', ->
    parsedMessage = { 
      html: "<p>#{this.loremIpsum}<p><br>\n",
      text: "#{this.loremIpsum}\n\n",
      headers: {
        'mime-version': '1.0',
        received: 'by 10.114.27.68 with HTTP; Sat, 12 May 2012 08:09:48 -0700 (PDT)',
        date: 'Sat, 12 May 2012 17:09:48 +0200',
        'delivered-to': 'webmail.testing.dev@gmail.com',
        'message-id': '<CALYsHJ4yFK_5owZ8TgmzqTnSrhqf7jnLnvgrc_u+tjNBYrGj8Q@mail.gmail.com>',
        subject: 'Bonjours Dori',
        from: 'Webmail Testing <webmail.testing.dev@gmail.com>',
        to: 'webmail.testing.dev@gmail.com',
        'content-type': 'multipart/alternative; boundary=047d7b624bde77714804bfd83eb3' 
      },
      subject: 'Hello You',
      priority: 'normal',
      from: [ 
        { 
          address: 'webmail.testing.dev@gmail.com',
          name: 'Webmail Testing' 
        } 
      ],
      to: [ 
        { 
          address: 'webmail.testing.dev@gmail.com', 
          name: '' 
        } 
      ] 
    }
    imapFields = 
      uid: 1000
      seqno: 100
      date: 'Mon, 17 Sep 2012 09:16:06 GMT'
      flags: ['Seen']
    _this = this
    Message.fromMailParser parsedMessage, imapFields, (message) ->
      expect(message.subject).to.equal 'Hello You'
      expect(message.from.name).to.equal 'Webmail Testing'
      expect(message.from.address).to.equal 'webmail.testing.dev@gmail.com'
      expect(message.to[0]).to.equal 'webmail.testing.dev@gmail.com'
      expect(message.body.text).to.equal "#{_this.loremIpsum}\n\n"
      expect(message.body.html).to.equal "<p>#{_this.loremIpsum}<p><br>\n"
      expect(message.seqno).to.equal 100
      expect(message.uid).to.equal 1000
      expect(message.flags[0]).to.equal 'Seen'
      expect(message.date).to.equal 'Mon, 17 Sep 2012 09:16:06 GMT'
      expect(message.from.md5).to.equal 'fa381def9e677a8e7f672ec2eabfaf3a'
      expect(message.sample).to.equal 'Lorem ipsum dolor sit amet, consectetur adipisicin...'

  it 'should save a message into database', (done)->
    message = new Message this.attr
    message.save 'testing@domain.tld', (err) ->
      expect(err).to.be.null
      Message.getByUID 'testing@domain.tld', message.uid, (err, gotMessage) ->
        expect(err).to.be.null
        expect(gotMessage.subject).to.equal message.subject
        done()




