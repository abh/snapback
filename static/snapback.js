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

var update_server_display = function(server) {

    console.log("updating", server);
    // find the existing record if it's there already
    var template = sb.template( $('#server_tmpl').html() );

    var server_div = $("div.server[data-server='" + server.name + "']");

    var html = template({ 'server': server });
  
    if (server_div.length > 0) {
        server_div.html(html);
    }
    else {
        $('#servers').append(html);
    }
};

var event_handler = function(e) {
      var msg = e;
      console.log("got payload", e);
      
      if (msg.status) {
        $('#log').prepend(msg.status + "<br>");
      }

      if (msg.type == 'mount' && msg.server && msg.server.name) {
         update_server_display(msg.server);
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
      console.log("running ajax form submit");
      event.preventDefault();
      var name = $add_server_form.find('input[name="server"]').val();
      $.ajax({ url: "/server/add",
               type: 'post',
               data: { 'token': sb.token, 'server': name },
               dataType: 'json',
               success: function(r) { console.log("added", r) }
             });
   });

   $.ajax({ url: "/server/",
            type: 'get',
            data: { 'token': sb.token, 'list': 1 },
            dataType: 'json',
            success: function(r) { 
              for (i in r) {
                  update_server_display(r[i]);
              }
            }
          });

});

