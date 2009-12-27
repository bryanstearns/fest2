class VenuesController < ApplicationController
  before_filter :require_admin_subscription, :except => [ :index, :show ]
  before_filter :load_festival, :except => :index

  # GET /venues
  # GET /venues.xml
  def index
    @festival = Festival.find_by_slug!(params[:festival_id], :include => :venues)
    check_festival_access
    @venues = @festival.venues

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.xml  { render :xml => @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    @venue = @festival.venues.find(params[:id])

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = @festival.venues.new

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # new.rjs
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @venue = @festival.venues.find(params[:id])

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # edit.rjs
    end
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = @festival.venues.new(params[:venue])
    @saved = @venue.save
    if @saved
      @new_venue = @festival.venues.new
    end

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # create.rjs
      if @saved
        format.xml  { render :xml => @venue, :status => :created, :location => @venue }
      else
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    @venue = @festival.venues.find(params[:id])
    @updated = @venue.update_attributes(params[:venue])

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # update.rjs
      if @updated
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue = @festival.venues.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # destroy.rjs
      format.xml  { head :ok }
    end
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id])
    check_festival_access
  end
end
