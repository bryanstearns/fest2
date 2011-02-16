// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// From http://henrik.nyh.se/2008/05/rails-authenticity-token-with-jquery
// (app layout has <%= javascript_tag "var AUTH_TOKEN = #{form_authenticity_token.inspect};" if protect_against_forgery? %>
//
jQuery(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

jQuery(function() {
  if (jQuery.browser.msie && parseInt(jQuery.browser.version) < 7) {
    jQuery(".badbrowser.ie6").show();
  }
  
  // Fix for jQuery on older iPads, which had broken offset()
  // from https://gist.github.com/661844
  // and http://bugs.jquery.com/ticket/6446
  if (parseFloat(((/CPU.+OS ([0-9_]{3}).*AppleWebkit.*Mobile/i.exec(navigator.userAgent)) || [0,'4_2'])[1].replace('_','.')) < 4.1) {
    jQuery.fn.Oldoffset = jQuery.fn.offset;
    jQuery.fn.offset = function() {
       var result = jQuery(this).Oldoffset();
       result.top -= window.scrollY;
       result.left -= window.scrollX;

       return result;
    }
  }

  // Toggle instructions based on cookie
  if (get_cookie("instructions") == "hide") {
    jQuery("#showhide span").html("show");
    jQuery("#instructions").hide();
  }
  jQuery("#showhide").click(function() {
    var instructions = jQuery("#instructions");
    var verb = instructions.css("display") != "none" ? "show" : "hide";
    jQuery("#showhide span").html(verb);
    set_cookie("instructions", verb == "show" ? "hide" : null, "never")
    instructions.toggle('fast');
  });
});

function client_type() {
  var ua = navigator.userAgent;
  if (ua.match(/iPad/)) return "tablet";
  return "desktop";
}

function client_is(type) {
  return client_type == type;
}

function set_cookie(name, value, expires, path, domain, secure) {
  var cookie = name + "=" + escape(value);
  if (!value) { // delete the cookie
    expires = new Date();
    expires.setTime(expires.getTime() - 1);
  }
  if (expires) {
    if (expires == "never")
      expires = new Date(2021, 12, 31);
    cookie += "; expires=" + expires.toGMTString();
  }
  if (path)
    cookie += "; path=" + escape(path);
  if (domain)
    cookie += "; domain=" + escape(domain);
  if (secure)
    cookie += "; secure";
  document.cookie = cookie;
}

function get_cookie(name) {
  var matches = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
  if (!matches)
    return null;
  return unescape(matches[2]);
}