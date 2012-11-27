describe 'Mail.Views.MailboxNameListView', ->

  beforeEach ->
    this.mailboxes = new Mail.Collections.MailboxList mailboxData
    this.view = new Mail.Views.MailboxNameListView
      collection: this.mailboxes
    this.$rendered = this.view.render().$el
    this.newMailbox =
      name: "New",
      id: 10,
      selectable: true,
      total: 12,
      unread: 0,
      mailboxId: null

  it 'should correctly display a collection of mailboxes', ->
    expect(this.$rendered.find('.mailbox').size()).toBe mailboxData.length

  it 'should re-render all the mailbox on reset event on collection', ->
    this.mailboxes.reset [this.newMailbox]
    expect(this.view.$el.find('.mailbox').size()).toBe 1

  it "should remove a mailbox when deleted from the collection", ->
    this.mailboxes.remove this.mailboxes.first()
    expect(this.view.$el.find('.mailbox').size()).toBe mailboxData.length-1

  it 'should display mailbox when added to the collection', ->
    this.mailboxes.add this.newMailbox
    expect(this.view.$el.find('.mailbox').size()).toBe mailboxData.length+1

  it 'should correctly render a parent mailbox (with an empty <ul>)', ->
    $childList = this.$rendered.find('#mailbox-5 ul')
    expect($childList[0]).toNotBe undefined
    expect($childList.children('li').size()).toBe 2