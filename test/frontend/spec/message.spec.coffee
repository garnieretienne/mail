describe 'Mail.Models.Message', ->

  it 'should create a new message and get correctly some attributes', ->
    msg = new Mail.Models.Message messageData[0]
    expect(msg.get('subject')).toBe 'Message number 0'
    expect(msg.get('from').name).toBe 'Etienne Garnier'

  it 'should ask if a message is marked with a specific flag', ->
    msg = new Mail.Models.Message messageData[0]
    expect(msg.flagged('Seen')).toBe true
    expect(msg.flagged('Draft')).toBe false