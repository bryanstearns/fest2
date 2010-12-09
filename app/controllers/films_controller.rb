class FilmsController < ApplicationController
  before_filter :require_admin_subscription, :except => [ 
    :index, :show
  ]
  # before_filter :disallow_html_edits, :except => [ :index, :show ]
  before_filter :load_festival, :except => [ :index ]
  
  # GET /festivals/1/films
  # GET /festivals/1/films.xml
  def index
    @festival = Festival.find_by_slug!(params[:festival_id], :include => :films)
    @films = @festival.films
    user_id = logged_in? ? current_user.id : 0
    @picks = Hash.new {|h, film_id| h[film_id] = Pick.new(:user_id => user_id,
                                                          :film_id => film_id) }
    Pick.find_all_by_festival_id_and_user_id(@festival.id, current_user.id)\
        .inject(@picks) {|h, p| h[p.film_id] = p; h} \
        if logged_in? 
    @show_press = if logged_in?
      sub = current_user.subscription_for(@festival)
      sub && sub.show_press
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @films }
    end
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
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id])
    check_festival_access
  end
end
