describe 'Mail.Models.Mailbox', ->

  it 'should create a new mailbox and get correctly some attributes', ->
    inbox = new Mail.Models.Mailbox mailboxData[0]
    expect(inbox.get('name')).toBe 'INBOX'
    expect(inbox.get('selectable')).toBe true