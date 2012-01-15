class VenuesController < ApplicationController
  before_filter :require_admin_subscription
  before_filter :load_location_and_festival, :only => [:new, :create]
  before_filter :load_venue_and_festival, :except => [:new, :create]

  # GET /locations/x/venues/new
  def new
    @venue = @location.venues.new
  end

  # POST /venues
  def create
    @venue = @location.venues.new(params[:venue].merge(:festival_id => @location.festival_id))
    if @venue.save
      flash[:notice] = 'Venue was successfully created.'
      redirect_to festival_locations_path(@festival)
    else
      render :action => :new
    end
  end

  # GET /locations/x/venues/1/edit
  def edit
  end

  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    if @venue.update_attributes(params[:venue].merge(:festival_id => @location.festival_id))
      flash[:notice] = 'Venue was successfully updated.'
      redirect_to festival_locations_path(@festival)
    else
      render :action => :edit
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue.destroy
    flash[:notice] = 'Venue was successfully deleted.'
    redirect_to festival_locations_path(@festival)
  end

protected
  def load_location_and_festival
    @location = Location.find(params[:location_id], :include => :festival)
    @festival = @location.festival
    check_festival_access
  end

  def load_venue_and_festival
    @venue = Venue.find(params[:id], :include => :festival)
    @festival = @venue.festival
    check_festival_access
  end
end
