Mail.Templates.mailboxNameTemplate = '
<% if(selectable) { %>
<a href="#"><%= name %></a>
<% } else { %>
<%= name %>
<% } %>
<% if(children > 0) { %>
<ul></ul>
<% } %>
'
