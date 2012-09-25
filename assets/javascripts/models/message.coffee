Mail.Models.Message = Backbone.Model.extend
  
  # Ask if a message is marked with a specific flag.
  # List of know system flags:
  # - Seen
  # - Answered
  # - Flagged
  # - Deleted
  # - Draft
  # - Recent
  flagged: (flag) ->
    if !(this.get('flags').indexOf(flag) == -1)
      return true
    return false

