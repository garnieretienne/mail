describe 'Mail.Views.MessageThumbView', ->

  it 'should correctly display a message thumb', ->
    msg = new Mail.Models.Message messageData[0]
    view = new Mail.Views.MessageThumbView
      model: msg
    $rendered = view.render().$el
    expect($rendered.attr('id')).toBe "message-thumb-#{msg.get('uid')}"
    expect($rendered.children('.date').text()).toBe msg.get('date')
    expect($rendered.find('.from > .from-avatar').attr('src')).toBe "http://www.gravatar.com/avatar/#{msg.get('from').md5}.png?d=mm"
    expect($rendered.find('.from > .from-avatar').attr('alt')).toBe msg.get('from').name
    expect($rendered.find('.from > .from-name').text()).toBe msg.get('from').name
    expect($rendered.find('.from > .from-email').text()).toBe msg.get('from').address
    expect($rendered.find('.subject').text()).toBe msg.get('subject')
    expect($rendered.find('p.sample').text()).toBe msg.get('sample')

  it 'should mark unread message', ->
    msg = new Mail.Models.Message messageData[1]
    view = new Mail.Views.MessageThumbView
      model: msg
    $rendered = view.render().$el
    expect($rendered.attr('class')).toMatch /unread/    