Mail.Templates.messageThumbTemplate = '
  <div class="date"><%= new Date(date).toDateString() %></div>
  <div class="from">
    <img class="img-rounded from-avatar" src="http://www.gravatar.com/avatar/<%= from.md5 %>.png?d=mm" alt="<%= from.name %>"/>
    <div class="from-name"><%= from.name %></div>
    <div class="from-email"><%= from.address %></div>
  </div>
  <div class="subject"><%= subject %></div>
'