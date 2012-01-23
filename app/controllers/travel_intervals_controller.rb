class TravelIntervalsController < ApplicationController
  before_filter :require_admin_subscription
  before_filter :load_festival_with_venues

  # GET /festivals/x/travel_intervals
  def index
    @venues = @festival.venues
    @intervals = @festival.travel_intervals.make_cache(nil)
  end

  def load_festival_with_venues
    load_festival(:include => [:venues])
  end
end
