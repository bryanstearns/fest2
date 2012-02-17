class WelcomeController < ApplicationController
  before_filter :require_admin, :only => :admin

  def index
    if logged_in? && request.path != '/home'
      # Send the user to a festival at the most appropriate phase
      user = current_user
      last_festival = cookies[:festival]
      festival = user.best_default_festival(last_festival)
      redirect_to best_user_path_for(festival, user) and return
    end

    session[:return_to] = root_url

    @festivals_cache_key = cache_prefix
    unless read_fragment(@festivals_cache_key)
      @current_festivals, @upcoming_festivals = \
        Festival.current.partition {|festival| festival.public? }

      # We'll show up to this many announcements on the front page; we'll only
      # show one if the newest isn't new.
      @announcements = Announcement.published(:limit => 3)
      @announcements = @announcements.each_with_index do |announcement, i|
        announcement if i == 0 || announcement.published_at > 2.weeks.ago
      end.compact
    end
  end

  def admin
  end

  def faq
  end

  def oops
  end

  protected

  def cache_prefix
    Festival.welcome_cache_key(current_user_role)
  end  
end
