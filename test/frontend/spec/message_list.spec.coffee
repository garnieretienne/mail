describe 'Mail.Collections.MessageList', ->

  it 'should create a new message list and get correctly each elements', ->
    messageArray = []
    for messageAttr in messageData
      message = new Mail.Models.Message messageAttr
      messageArray.push message
    messages = new Mail.Collections.MessageList messageArray
    messages.forEach (message) ->
      expect(message.get('subject')).toNotBe undefined
    