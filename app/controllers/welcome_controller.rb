class WelcomeController < ApplicationController
  def index
    session[:return_to] = request.request_uri

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
