Mail.Collections.MessageList = Backbone.Collection.extend
  model: Mail.Models.Message
  url: "/messages"