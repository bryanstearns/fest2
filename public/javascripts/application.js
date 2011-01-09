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
});

function client_type() {
  var ua = navigator.userAgent;
  if (ua.match(/iPad/)) return "tablet";
  return "desktop";
}

function client_is(type) {
  return client_type == type;
}
