class PicksController < ApplicationController
  # POST /films/1/picks
  # POST /films/1/picks.xml
  def create
    @pick = current_user.picks.find_or_initialize_by_film_id(
              params[:film_id], :include => { :film => :festival })
    @film = @pick.film
    @festival = @film.festival
    check_festival_access
    
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
