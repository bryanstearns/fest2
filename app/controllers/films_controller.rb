class FilmsController < ApplicationController
  before_filter :require_admin_subscription

  # before_filter :disallow_html_edits, :except => [ :show ]
  before_filter :load_festival, :except => [ :index ]
  before_filter :load_festival_venues_films_screenings, :only => [ :index ]

  # GET /festivals/1/films
  def index
  end

  # GET /festivals/1/films/1
  # GET /festivals/1/films/1.xml
  def show
    @film = @festival.films.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @film }
    end
  end

  # GET /festivals/1/films/new
  # GET /festivals/1/films/new.xml
  def new
    @film = @festival.films.new
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # new.rjs
      format.xml  { render :xml => @film }
    end
  end

  # GET /festivals/1/films/1/edit
  def edit
    @film = @festival.films.find(params[:id])
  end

  # POST /festivals/1/films
  # POST /festivals/1/films.xml
  def create
    @film = @festival.films.new(params[:film])
    @saved = @film.save
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js
      if @saved
        format.xml  { render :xml => @film, :status => :created, :location => @film }
      else
        format.xml  { render :xml => @film.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /festivals/1/films/1
  # PUT /festivals/1/films/1.xml
  def update
    @film = @festival.films.find(params[:id])
    @updated = @film.update_attributes(params[:film])
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # update.rjs
      if @updated
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @film.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /festivals/1/films/1
  # DELETE /festivals/1/films/1.xml
  def destroy
    @film = @festival.films.find(params[:id])
    @film.destroy

    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js # destroy.rjs
      format.xml  { head :ok }
    end
  end

protected
  def load_festival_venues_films_screenings
    load_festival(:include => [:venues, { :films => :screenings }])
    @films = @festival.films
    @venues = @festival.venues
  end
end
