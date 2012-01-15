class LocationsController < ApplicationController
  before_filter :require_admin_subscription
  before_filter :load_festival

  # GET /festivals/x/locations
  def index
    @locations = @festival.locations
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id], :include => { :locations => :venues })
    check_festival_access
  end
end
