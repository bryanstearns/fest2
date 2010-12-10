class WelcomeController < ApplicationController
  def index
    session[:return_to] = request.request_uri
    today = Date.today

    @festivals_cache_key = cache_prefix
    unless read_fragment(@festivals_cache_key)
      @have_old = false
      @festivals = Festival.send(find_scope(false)).inject([]) do |a, f|
        a << if f.ends < today
          @have_old = true
          nil
        else
          f
        end
        a
      end.compact
    end

    @announcement_limit = 2
    @announcements_cache_key = cache_prefix + "/announcements"
    unless read_fragment(@announcements_cache_key)
      @announcements = \
        Announcement.published.all(:limit => @announcement_limit + 1)
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
