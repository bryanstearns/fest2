class WelcomeController < ApplicationController
  def index
    if logged_in? && request.path != '/home'
      # Send the user to a festival at the most appropriate phase
      user = current_user
      festival = user.festivals.best_default(cookies[:festival])
      if user.has_screenings_for(festival)
        redirect_to festival_path(festival) and return
      elsif user.has_rankings_for(festival)
        redirect_to festival_assistant_path(festival) and return
      else
        redirect_to festival_films_path(festival) and return
      end
    end

    session[:return_to] = root_url

    @festivals_cache_key = cache_prefix
    unless read_fragment(@festivals_cache_key)
      @current_festivals, @upcoming_festivals = \
        Festival.current.partition {|festival| festival.public? }
    end
  end

  def faq
  end

  def oops
  end

  protected

  def cache_prefix
    role = logged_in? \
      ? (current_user.admin ? "admin" : "user") \
      : "guest"
    "welcome/#{Date.today}/#{role}"
  end  
end
