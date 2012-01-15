class LocationsController < ApplicationController
  before_filter :require_admin_subscription
  before_filter :load_festival

  # GET /festivals/x/locations
  def index
    @locations = @festival.locations
  end

  # GET /festivals/x/locations/new
  def new
    @location = @festival.locations.build
  end

  # POST /festivals/x/locations
  def create
    @location = @festival.locations.new(params[:location])
    if @location.save
      flash[:notice] = 'Location was successfully created.'
      redirect_to festival_locations_path(@festival)
    else
      render :action => :new
    end
  end

  # GET /festivals/x/locations/edit
  def edit
    @location = @festival.locations.find(params[:id])
  end

  # PUT /festivals/x/locations/x
  def update
    @location = @festival.locations.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = 'Location was successfully updated.'
      redirect_to festival_locations_path(@festival)
    else
      render :action => :edit
    end
  end

  # DELETE /festivals/x/locations/x
  def destroy
    @location = @festival.locations.find(params[:id])
    @location.destroy
    flash[:notice] = 'Location was successfully deleted.'
    redirect_to festival_locations_path(@festival)
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id], :include => { :locations => :venues })
    check_festival_access
  end
end
