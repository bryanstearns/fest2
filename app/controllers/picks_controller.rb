class PicksController < ApplicationController
  # GET /festivals/1/priorities
  # GET /festivals/1/priorities.xml
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


  # POST /films/1/picks
  # POST /films/1/picks.xml
  def create
    @pick = current_user.picks.find_by_film_id(params[:film_id],
                                               :include => { :film => :festival }) ||
            current_user.picks.build(:film_id => params[:film_id])
    @film = @pick.film
    @festival = @film.festival
    check_festival_access

    params[:pick] = { params[:attribute].to_sym => nil } if params[:pick].nil?
    @updated = @pick.update_attributes(params[:pick])

    respond_to do |format|
      format.js  # create.rjs
      if @updated
        format.xml  { render :xml => @pick, :status => :created, :location => @pick }
      else
        format.xml  { render :xml => @pick.errors, :status => :unprocessable_entity }
      end
    end
  end
end
