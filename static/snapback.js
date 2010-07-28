/*! Copyright 2010 Ask Bjørn Hansen
 */

  if (!sb) var sb = {};

  sb.escape_html = function(text) {
    if (_.isUndefined(text)) return "";
    return text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  sb.unescape_html = function(text) {
    if (_.isUndefined(text)) return "";
    return text.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
  }

  sb.template = function(str, data) {
    var fn = new Function('obj',
      'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'with(obj){p.push(\'' +
      str
        .replace(/[\r\t\n]/g, " ")
        .split("<\?").join("\t")
        .replace(/((^|\?>)[^\t]*)'/g, "$1\r")
        .replace(/\t==(.*?)\?>/g, "',$1,'")
        .replace(/\t=(.*?)\?>/g, "', sb.escape_html($1),'")
        .split("\t").join("');")
        .split("\?>").join("p.push('")
        .split("\r").join("\\'")
    + "');}return p.join('');");
    return data ? fn(data) : fn;
  };

var event_handler = function(e) {
      var msg = e;
      console.log("got payload", e);
      
      if (msg.status) {
        $('#log').prepend(msg.status + "<br>");
      }

      if (msg.type == 'mount' && msg.server && msg.server.name) {
         // find the existing record if it's there already
         var template = sb.template( $('#server_tmpl').html() );

         var server = $("div.server[data-server='" + msg.server.name + "']");

         var html = template({ 'server': msg.server });
  
         console.log("html", html);
  
         if (server.length > 0) {
            server.html(html);
         }
         else {
            console.log("appending", html);
            $('#servers').append(html);
         }
      }

      console.log("msg", msg);
      return false;
};


$(document).ready(function () {

   var ident = $.cookie("sid");
   $.ev.handlers['*'] = event_handler;
   $.ev.loop('/poll?client_id=' + ident);

   var  $add_server_form = $("#add-server-form");
   $add_server_form.find('input:first').focus();
   $add_server_form.find('input:submit').click(function(event) {
      event.preventDefault();
      var name = $add_server_form.find('input[name="server"]').val();
      $.ajax({ url: "/server/add",
               method: 'post',
               data: { 'token': sb.token, 'server': name },
               success: function(r) { }
             });
   });

 

});

