class SubscriptionsController < ApplicationController
  before_filter :login_required, :except => [ :show ]
  before_filter :load_festival

  # GET /festivals/1/settings
  def show
    if logged_in? 
      @subscription = current_user.subscription_for(@festival, :create => true)
      @ask_about_unselection = current_user.has_screenings_for(@festival)
    else
      @subscription = Subscription.new
      @ask_about_unselection = false
    end
  end

  # PUT /festivals/1/settings
  # PUT /festivals/1/settings.xml
  def update
    @subscription = current_user.subscription_for(@festival, :create => true)

    respond_to do |format|
      good = @subscription.update_attributes(params[:subscription])
      if good
        # flash[:notice] = 'Settings successfully saved.'
        sched = AutoScheduler.new(current_user, @festival, 
                                  @subscription.unselect)
        begin
          scheduled_count, prioritized_count = sched.go
          flash[:notice] = "#{scheduled_count} of the #{view_helper.pluralize(prioritized_count, "film")} you've prioritized #{scheduled_count == 1 ? "is" : "are"} scheduled for you."
        rescue AutoSchedulingError => e
          good = false
          flash[:warning] = e.message
        end
      end
        
      if good
        format.html do
          redirect_to festival_url(@festival)
        end
        format.xml  { head :ok }
      else
        format.html do 
          @ask_about_unselection = current_user.has_screenings_for(@festival)
          render :action => "show"
        end
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id], :include => :screenings)
    check_festival_access
  end
end
