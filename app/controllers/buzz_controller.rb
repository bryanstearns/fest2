class BuzzController < ApplicationController
  before_filter :load_film, :only => [:index, :new, :create]

  # GET /buzz
  def index
    @buzz = Buzz.all
  end

  # GET /buzz/1
  def show
    @buzz = Buzz.find(params[:id])
  end

  # GET /buzz/new
  def new
    @buzz = Buzz.new
  end

  # GET /buzz/1/edit
  def edit
    @buzz = Buzz.find(params[:id])
  end

  # POST /buzz
  def create
    @buzz = Buzz.new(params[:buzz])
    if @buzz.save
      redirect_to(@buzz, :notice => 'Buzz was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /buzz/1
  def update
    @buzz = Buzz.find(params[:id])
    if @buzz.update_attributes(params[:buzz])
      redirect_to(@buzz, :notice => 'Buzz was successfully updated.')
    else
      render :action => "edit"
    end
  end

# We don't destroy notes - we just un-publish them
#  # DELETE /buzz/1
#  def destroy
#    @buzz = Buzz.find(params[:id])
#    @buzz.destroy
#    redirect_to(buzz_url)
#  end

protected
  def load_film
    @film = Film.find(params[:film_id])
  end
end
