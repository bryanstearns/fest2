class VenueGroupsController < ApplicationController
  before_filter :require_admin_subscription
  before_filter :load_festival

  # GET /festivals/x/locations
  def index
    @festival = Festival.find_by_slug!(params[:festival_id], :include => :venues)
    check_festival_access
    @venues = @festival.venues
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id], :include => { :venue_groups => :venues })
    check_festival_access
  end
end
