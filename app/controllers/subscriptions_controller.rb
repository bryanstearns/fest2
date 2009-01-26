class SubscriptionsController < ApplicationController
  before_filter :login_required
  before_filter :load_festival

  # GET /festivals/1/settings
  def show
    @subscription = current_user.subscription_for(@festival, :create => true)
  end

  # PUT /festivals/1/settings
  # PUT /festivals/1/settings.xml
  def update
    @subscription = current_user.subscription_for(@festival, :create => true)

    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        flash[:notice] = 'Settings successfully saved.'
        format.html { redirect_to(@festival) }
        format.xml  { head :ok }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

protected
  def load_festival
    @festival = Festival.find_by_slug(params[_[:festival_id]])
    check_festival_access
  end
end
