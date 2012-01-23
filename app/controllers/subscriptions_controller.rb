class SubscriptionsController < ApplicationController
  before_filter :login_required, :except => [ :show ]
  before_filter :load_festival_with_screenings

  # GET /festivals/1/settings
  def show
    if logged_in? 
      @subscription = current_user.subscription_for(@festival, :create => true)
      @ask_about_unselection = current_user.has_screenings_for(@festival)
    else
      @subscription = @festival.subscriptions.build
      @ask_about_unselection = false
    end
  end

  # PUT /festivals/1/settings
  # PUT /festivals/1/settings.xml
  def update
    @subscription = current_user.subscription_for(@festival, :create => true)

    notice = warning = nil
    respond_to do |format|
      good = @subscription.update_attributes(params[:subscription])
      if good
        # flash[:notice] = 'Settings successfully saved.'
        sched = AutoScheduler.new(current_user, @festival, 
                                  @subscription.unselect)
        begin
          scheduled_count, prioritized_count = sched.go
          notice = "#{scheduled_count} of the #{view_helper.pluralize(prioritized_count, "film")} you've prioritized #{scheduled_count == 1 ? "is" : "are"} scheduled for you."
        rescue AutoSchedulingError => e
          good = false
          warning = e.message
        end
      end
        
      if good
        format.html do
          flash[:notice] = notice
          redirect_to festival_url(@festival)
        end
        format.xml  { head :ok }
      else
        format.html do
          flash.now[:warning] = warning
          @ask_about_unselection = current_user.has_screenings_for(@festival)
          render :action => "show"
        end
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

protected
  def load_festival_with_screenings
    load_festival(:include => :screenings)
  end
end
