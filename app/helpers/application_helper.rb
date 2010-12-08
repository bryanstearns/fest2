# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def javascript_includes
    jquery_version = "1.4.4"
    jquery_ui_version = "1.8.6"        
    javascripts = []
    script_includes = []
    if Rails.env.production?
      script_includes << "<script type=\"text/javascript\" " +
        "src=\"http://ajax.googleapis.com/ajax/libs/jquery/" +
        jquery_version + "/jquery.min.js\"></script>"
    else
      javascripts << "jquery-1.4.4"
    end
    javascripts << "jquery-ui-#{jquery_ui_version}.custom.min"
    javascripts << "jqtouch" if request.format == :mobile
    javascripts << "application"
    "#{script_includes.join("\n")}\n" + javascript_include_tag(javascripts)
  end
end
