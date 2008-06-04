class WelcomeController < ApplicationController
  def index
    session[:return_to] = request.request_uri
    today = Date.today
    @past_festivals, @upcoming_festivals = Festival.send(find_scope(false), :all).partition { |f| f.ends < today }
    @announcement_limit = 2
    @announcements = Announcement.send("find_#{_[:festivals]}", :all, 
      :limit => @announcement_limit + 1)

    @amazon_limit = 3
    if conference_mode
      @amazon_films = []
    else
      @amazon_films = Film.find_amazon(:all)
      if @amazon_films.size > @amazon_limit
        cut = rand(@amazon_films.size) # cut the deck to a random spot
        @amazon_films = (@amazon_films[cut..-1] + @amazon_films[0...cut])[0..@amazon_limit]
      end
    end
  end
  
  def dvds
    @amazon_films = Film.find_amazon(:all, :order => :name)
  end
end
