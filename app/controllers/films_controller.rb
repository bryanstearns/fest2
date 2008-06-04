class FilmsController < ApplicationController
  before_filter :require_admin_subscription, :except => [ 
    :index, :show, :dvd
  ]
  # before_filter :disallow_html_edits, :except => [ :index, :show ]
  before_filter :load_festival, :except => [ 
    :index, :dvd, :amazon, :amazon_lookup, :amazon_confirm 
  ]
  
  # GET /festivals/1/films
  # GET /festivals/1/films.xml
  def index
    festival_id = params[_[:festival_id]]
    raise(ActiveRecord::RecordNotFound) unless festival_id
    @festival = Festival.find_by_slug(festival_id, :include => { :films => :screenings })
    raise(ActiveRecord::RecordNotFound) unless @festival.is_conference == conference_mode
    @films = @festival.films
    @picks = Hash.new {|h, film_id| h[film_id] = current_user.picks.new(:film_id => film_id) }
    Pick.find_all_by_festival_id_and_user_id(@festival.id, current_user.id)\
        .inject(@picks) {|h, p| h[p.film_id] = p; h} if logged_in?
    
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

  # GET /films/amazon
  def amazon
    films = Film.find(:all, :include => :festival, 
                       :conditions => ['amazon_url is not null or amazon_data is not null'])
    @festivals = films.group_by(&:festival)
  end

  # POST /films/amazon_lookup
  def amazon_lookup
    @festivals = Festival.find(:all, :include => :films)
    @festivals.each do |fest|
      fest.films.each do |film|
        if film.amazon_url.blank?
          results = Amazon::lookup(film.name)
          if results
            film.amazon_data = results.to_yaml
            film.save!
          end
        end
      end
    end
    redirect_to :action => "amazon"
  end

  # POST /films/1/amazon_confirm?choice=[cancel,accept,reject]
  def amazon_confirm
    @film = Film.find(params[:id])
    case params[:choice]
      when "cancel"
        @film.amazon_ad = @film.amazon_url = nil
      when "delete"
        @film.amazon_data = nil
      else
        info = YAML.load(@film.amazon_data).detect { |d| d[:asin] == params[:choice] }
        @film.amazon_ad = YAML.dump(info)
        @film.amazon_url = info[:url]
    end
    updated = @film.save
    
    respond_to do |format|
      format.html { raise NonAjaxEditsNotSupported }
      format.js do
        render :update do |page|
          if updated
            page.replace dom_id(@film), :partial => 'films/film_at_amazon', :object => @film
          else
            page.alert flash[:notice]
            flash.discard
          end
        end
      end
    end
  end

  def dvd
    @film = Film.find(params[:id])
    raise(ActiveRecord::RecordNotFound) unless @film and @film.amazon_url
    redirect_to @film.amazon_url
  end

protected
  def load_festival
    @festival = Festival.find_by_slug(params[_[:festival_id]])
    check_festival_access
  end
end
