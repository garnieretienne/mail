describe 'Mail.Views.MailboxNameView', ->

  it 'should correctly display a mailbox', ->
    mailbox = new Mail.Models.Mailbox mailboxData[0]
    view = new Mail.Views.MailboxNameView
      model: mailbox
    $rendered = view.render().$el
    expect($rendered.attr('id')).toBe "mailbox-#{mailbox.id}"
    expect($rendered.attr('class')).toBe "mailbox"
    expect($rendered.children('a').text()).toBe "INBOX"
    expect($rendered.children('ul')[0]).toBe undefined

  it 'should correctly render a non-selectable mailbox', ->
    mailbox = new Mail.Models.Mailbox mailboxData[4]
    view = new Mail.Views.MailboxNameView
      model: mailbox
    $rendered = view.render().$el
    expect($rendered.attr('id')).toBe "mailbox-#{mailbox.id}"
    expect($rendered.attr('class')).toBe "mailbox"
    expect($rendered.text()).toBe "Parent"