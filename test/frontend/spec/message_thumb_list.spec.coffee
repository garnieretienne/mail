describe 'Mail.Views.MessageThumbListView', ->

  beforeEach ->
    this.messages = new Mail.Collections.MessageList messageData
    this.view = new Mail.Views.MessageThumbListView
      collection: this.messages
    this.$rendered = this.view.render().$el
    this.newMessage = 
      uid: 3
      subject: 'Message number 0'
      from:
        name: 'Etienne Garnier'
        address: 'etienne.garnier@domain.tld'
        md5: "64fe483361c5f1b54973f27b8a0b4df5"
      to: ['me@domain.tld', 'another.person@domain.tld']
      date: 'Mon, 17 Sep 2012 09:16:06 GMT'
      sample: "balh blah blah blah blah blah blah"
      flags: ['Seen', 'Answered']

  it 'should correctly display a collection of messages', ->
    expect(this.$rendered.children('.message-thumb').size()).toBe messageData.length

  it 'should re-render all the message on reset event on collection', ->
    this.messages.reset [this.newMessage]
    expect(this.view.$el.children('.message-thumb').size()).toBe 1

  it 'should remove message thumb when message is removed from the collection', ->
    this.messages.remove this.messages.first()
    expect(this.view.$el.children('.message-thumb').size()).toBe messageData.length-1

  it 'should display new message thumb when new message is added to the collection', ->
    this.messages.add this.newMessage
    expect(this.view.$el.children('.message-thumb').size()).toBe messageData.length+1