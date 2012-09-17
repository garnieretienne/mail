# Messages sample
messageData = [{
  uid: 1
  subject: 'Message number 0'
  from: 
    name: 'Etienne Garnier'
    email: 'etienne.garnier@domain.tld'
  date: 'Mon, 17 Sep 2012 09:16:06 GMT'
  to: ['me@domain.tld', 'another.person@domain.tld']
  flags: ['Seen', 'Answered']
}, {
  uid: 2
  subject: 'Message number 1'
  from: 
    name: 'Lucky Luke'
    email: 'lulu@domain.tld'
  date: 'Mon, 19 Sep 2012 09:16:06 GMT'
  to: ['me@domain.tld']
  flags: []
}]


# Specs
describe 'Mail.Models.Message', ->

  it 'should create a new Message and get correctly some attributes', ->
    msg = new Mail.Models.Message messageData[0]
    expect(msg.get('subject')).toBe('Message number 0')
    expect(msg.get('from')['name']).toBe('Etienne Garnier')

