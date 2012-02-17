class CacheExpirationObserver < ActionController::Caching::Sweeper
  observe :festival, :screening, :venue, :film, :announcement

  def after_create(record)
    # update the festival list on the welcome page
    [:admin, :user, :guest].each {|role| expire_one_fragment(Festival.welcome_cache_key(role)) }

    festival = case record
    when Festival
      record
    when Announcement
      nil
    else
      record.festival
    end

    # update the festival's grid
    [false, true].each {|show_press| expire_one_fragment(festival.cache_key(show_press)) } \
      if festival
  end
  alias_method :after_update, :after_create
  alias_method :after_destroy, :after_create

  def expire_one_fragment(key)
    Rails.logger.info("Expiring cache key: #{key}")
    expire_fragment(key)
  end
end
