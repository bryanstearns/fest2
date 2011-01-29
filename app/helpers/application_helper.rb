# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation
    linknames = ["Home", "News", "Festivals", "FAQ", "Feedback"]
    if logged_in?
      linknames << "Log out"
    else
      linknames << "Sign up"
      linknames << "Log in"
    end
    linknames.map do |name|
      url_name = name.gsub(/ /,'').downcase
      url = send("#{url_name}_url".to_sym)
      link_to(name, url) unless (current_page?(url) or (request.path == '/' and url_name == 'home'))
    end.compact.join(' ')
  end

  def site_name
    link = "Festival Fanatic"
    link = link_to(link, home_url) \
      unless (current_page?(home_url) or current_page?(root_url))
    if logged_in?
      "<span>#{current_user.username}</span> is a #{link}!"
    else
      "Are you a #{link}?"
    end
  end

  def this_these(collection, name)
    if collection.size == 1
      "this #{name}"
    else
      "these #{name.pluralize}"
    end
  end
  
  def stylesheet_includes(jquery_ui_version)
    families = ["Droid Sans", "Droid Sans:bold", "Droid Serif", "Droid Serif:bold"]
    results = ["<link rel=\"stylesheet\" type=\"text/css\" " +
               "href=\"http://fonts.googleapis.com/css?family=#{families.join('|').gsub(' ', '+')}\">"]

    results += [
      stylesheet_link_tag('compiled/screen', :media => 'screen, projection'),
      stylesheet_link_tag('compiled/print', :media => 'print'),
      "<!--[if IE 6]>",
      stylesheet_link_tag('compiled/ie', :media => 'screen, projection'),
      "<![endif]-->"
    ]
    results.join("\n")
  end

  def javascript_includes(jquery_version, jquery_ui_version)
    javascripts = []
    script_includes = []
    javascripts += %w[prototype effects dragdrop controls]
    # For some reason, this include was causing javascript errors in production
    # (somewhere in the middle of prototype). So, don't use Google for now.
    if false #Rails.env.production?
      script_includes << \
        "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/" +
        jquery_version + "/jquery.min.js\" type=\"text/javascript\"></script>"
    else
      javascripts << "jquery-1.4.4"
    end
    javascripts << "jquery-ui-#{jquery_ui_version}.custom.min" \
      if jquery_ui_version
    # javascripts << "jquery.qtip-1.0.0-rc3.min"
    javascripts << "jquery.form"
    javascripts << "jqtouch" if client_is?(:mobile)
    javascripts << "application"
    "#{script_includes.join("\n")}\n" + javascript_include_tag(javascripts)
  end

  def best_user_path_for(festival, user)
    if user.nil? or festival.ends < Date.today or user.has_screenings_for(festival)
      festival_path(festival)
    elsif user.has_rankings_for(festival)
      festival_assistant_path(festival)
    else
      festival_films_path(festival)
    end
  end
end
