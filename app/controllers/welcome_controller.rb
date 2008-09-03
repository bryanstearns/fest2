class WelcomeController < ApplicationController
  def index
    session[:return_to] = request.request_uri
    today = Date.today
    @festivals_cache_key = "/welcome/%{_[:festivals]}/%{today}"
    unless read_fragment(@festivals_cache_key)
      @past_festivals, @upcoming_festivals = Festival.send(find_scope(false)).partition { |f| f.ends < today }
    end
    @announcements_cache_key = "/welcome/announcements/%{today}"
    unless read_fragment(@announcements_cache_key)
      @announcement_limit = 2
      @announcements = Announcement.send(_[:festivals]).find(:all, 
        :limit => @announcement_limit + 1)
    end

    @amazon_limit = 3
    if conference_mode
      @amazon_films = []
    else
      @amazon_films = Film.on_amazon
      if @amazon_films.size > @amazon_limit
        cut = rand(@amazon_films.size) # cut the deck to a random spot
        @amazon_films = (@amazon_films[cut..-1] + @amazon_films[0...cut])[0..@amazon_limit]
      end
    end
  end
  
  def dvds
    @amazon_films = Film.on_amazon(:all, :order => :name)
  end
end
