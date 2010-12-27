class WelcomeController < ApplicationController
  def index
    if logged_in? && request.path != '/home'
      # Send the user to a festival at the most appropriate phase
      user = current_user
      last_festival = cookies[:festival]
      festival = user.best_default_festival(cookies[:festival])
      redirect_to best_user_path_for(festival, user) and return
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
      ? (current_user_is_admin? ? "admin" : "user") \
      : "guest"
    "welcome/#{Date.today}/#{role}"
  end  
end
