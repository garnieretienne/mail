describe 'Mail.Collections.MessageList', ->
  
  it 'should possibly fetch using the good url', ->
    messages = new Mail.Collections.MessageList messageData
    expect(messages.url).toBe '/messages'
    