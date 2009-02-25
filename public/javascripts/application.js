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
});
