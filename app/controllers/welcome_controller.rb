class WelcomeController < ApplicationController
  def index
    session[:return_to] = request.request_uri
    today = Date.today

    @festivals_cache_key = cache_prefix
    unless read_fragment(@festivals_cache_key)
      @past_festivals, @upcoming_festivals = Festival.send(find_scope(false)).partition { |f| f.ends < today }
    end

    @announcement_limit = 2
    @announcements_cache_key = cache_prefix + "/announcements"
    unless read_fragment(@announcements_cache_key)
      @announcements = Announcement.send(_[:festivals]).find(:all, 
        :limit => @announcement_limit + 1)
    end
    
    load_amazon_films(3)
  end

  def dvds
    load_amazon_films
  end

  protected

  def cache_prefix
    "#{_[:festivals]}/welcome/#{Date.today}"
  end

  def load_amazon_films(limit=nil)
    @amazon_limit = limit
    @amazon_cache_key = cache_prefix + "/amazon"
    unless read_fragment(@amazon_cache_key)
      @amazon_films = conference_mode ? [] : Film.on_amazon
    end
  end
  
end
