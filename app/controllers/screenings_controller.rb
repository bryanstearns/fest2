class ScreeningsController < ApplicationController
  before_filter :require_admin_subscription, :except => [ :index, :show ]
  before_filter :load_film, :except => :index
  
  # GET /films/1/screenings
  # GET /films/1/screenings.xml
  def index
    @film = Film.find(params[:film_id], :include => [:festival, {:screenings => :venue }])
    @screenings = @film.screenings
    @festival = @film.festival
    check_festival_access
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.xml  { render :xml => @screenings }
    end
  end

  # GET /films/1/screenings/1
  # GET /films/1/screenings/1.xml
  def show
    @screening = @film.screenings.find(params[:id], :include => [:venue, :film, :festival])

    @other_screenings = @film.screenings.reject do |s|
      (s == @screening) || (current_user ? current_user.can_see?(s) : s.press)
    end
    @earlier_screenings, @later_screenings = @other_screenings.partition {|s| s.starts < @screening.starts }
    
    @pick = (@film.picks.find_by_user_id(current_user.id) \
             || current_user.picks.new(:film_id => @film.id)) \
            if logged_in?
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js
      format.xml { render :xml => @screening }
    end
  end

  # GET /films/1/screenings/new
  # GET /films/1/screenings/new.xml
  def new
    @screening = @film.screenings.new

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # new.rjs
      format.xml  { render :xml => @screening }
    end
  end

  # GET /films/1/screenings/1/edit
  def edit
    @screening = @film.screenings.find(params[:id])
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # edit.rjs
    end
  end

  # POST /films/1/screenings
  # POST /films/1/screenings.xml
  def create
    @screening = @film.screenings.new(params[:screening])
    @saved = @screening.save
    if @saved
      @new_screening = @film.screenings.new
      @new_screening.starts = @screening.starts      
    end
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # create.rjs
      if @saved
        format.xml  { render :xml => @screening, :status => :created, :location => @screening }
      else
        format.xml  { render :xml => @screening.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /films/1/screenings/1
  # PUT /films/1/screenings/1.xml
  def update
    @screening = @film.screenings.find(params[:id])
    @updated = @screening.update_attributes(params[:screening])
    if @updated
      @new_screening = @film.screenings.new
      @new_screening.starts = @screening.starts      
    end

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # update.rjs
      if @updated
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @screening.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /films/1/screenings/1
  # DELETE /screenings/1.xml
  def destroy
    @screening = @film.screenings.find(params[:id])
    @screening.destroy

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # destroy.rjs
      format.xml  { head :ok }
    end
  end

protected
  def load_film
    @film = Film.find(params[:film_id], :include => :festival)
    @festival = @film.festival
    check_festival_access
  end
end
