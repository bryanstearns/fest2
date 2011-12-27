module FilmsHelper
  def toggleable(label, tag=:div, &block)
    # Emit this label, and whatever content is produced by the block 
    # given, such that clicking on the label will toggle visibility 
    # of the content.
    concat "<label>#{label}</label><#{tag.to_s} style=\"display: none;\">"
    yield
    concat "</#{tag.to_s}>"
  end
  
  def link_to_film(film, options={})
    # If have an external link to this film, emit it; otherwise, just emit the
    # name as a <span>..</span>
    name = h(film.name)
    url = film.festival.external_film_url(film)
    
    url ? content_tag(:a, name, options.merge!(:href => url)) :
          content_tag(:span, name, :class => options[:class] || "name")
  end
  
  def priority_widget(film, user, pick)
    # Emit a widget that lets a user prioritize this film.
    priority = pick.nil? ? "nil" : pick.priority
    image_tag(image_path("priority/#{priority}.png"), :class => "priority",
              :title => "click a bar to prioritize this film")
  end
  
  def ranking_hints
    # We index into this list when making ranking-widget tooltips
    {
      'cancel' => "Forget this choice for now",
      0 => "I don't want to see this: never schedule it for me",
      1 => "I'd see this if nothing higher-priority was showing",
      2 => "I'd like to see this",
      4 => "I'd very much like to see this",
      8 => "I *really* want to see this!"
    }
  end

end
