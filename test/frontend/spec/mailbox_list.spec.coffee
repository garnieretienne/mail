describe 'Mail.Collections.MailboxList', ->

  it 'should create a new mailbox list and get correctly each elements', ->
    mailboxArray = []
    for mailboxAttr in mailboxData
      mailbox = new Mail.Models.Mailbox mailboxAttr
      mailboxArray.push mailbox
    mailboxes = new Mail.Collections.MailboxList mailboxArray
    mailboxes.forEach (mailbox) ->
      expect(mailbox.get('name')).toNotBe undefined

  it 'should tell if a mailbox has a parent', ->
    mailboxArray = []
    for mailboxAttr in mailboxData
      mailbox = new Mail.Models.Mailbox mailboxAttr
      mailboxArray.push mailbox
    mailboxes = new Mail.Collections.MailboxList mailboxArray
    child1 = mailboxes.find (mailbox) ->
      mailbox.get('name') == 'Child1'
    expect(child1.getParent().get('name')).toBe 'Parent'
    inbox = mailboxes.find (mailbox) ->
      mailbox.get('name') == 'INBOX'
    expect(inbox.getParent()).toBe null

  it 'should tell if a mailbox has children', ->
    mailboxArray = []
    for mailboxAttr in mailboxData
      mailbox = new Mail.Models.Mailbox mailboxAttr
      mailboxArray.push mailbox
    mailboxes = new Mail.Collections.MailboxList mailboxArray
    parent = mailboxes.find (mailbox) -> mailbox.get('name') == 'Parent'
    children = parent.getChildren()
    expect(children.length).toBe 2
    inbox = mailboxes.find (mailbox) -> mailbox.get('name') == 'INBOX'
    expect(inbox.getChildren()[0]).toBe undefined
