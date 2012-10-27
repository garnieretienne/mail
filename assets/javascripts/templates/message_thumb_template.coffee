Mail.Templates.messageThumbTemplate = '
  <div class="date"><%= new Date(date).toDateString() %></div>
  <div class="from">
    <div class="gravatar" data-src="http://www.gravatar.com/avatar/<%= from.md5 %>.png?d=404" data-name="<%= from.name %>"/>
    <div class="from-name"><%= from.name %></div>
    <div class="from-email"><%= from.address %></div>
  </div>
  <div class="subject"><%= subject %></div>
'
