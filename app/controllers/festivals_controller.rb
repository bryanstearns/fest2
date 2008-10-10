class FestivalsController < ApplicationController
  before_filter :require_admin_subscription, :except => \
    [:index, :show, :pick_screening, :schedule, :schedule_continue,
     :reset_rankings, :reset_screenings, :update_days]
  
  # GET /festivals
  # GET /festivals.xml
  def index
    @festivals = Festival.send(find_scope) || raise(RecordNotFound)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @festivals }
    end
  end

  # GET /festivals/1
  # GET /festivals/1.xml
  # GET /festivals/1.ical
  def show
    @festival = Festival.find_by_slug(params[:id])
    check_festival_access
    @cache_key = "#{_[:festivals]}/show/#{params[:id]}/#{@festival.updated_at.to_i}/#{logged_in?.inspect}"
    @screening_javascript = screening_settings_to_js
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @festival }
      format.ical do
        redirect_to login_url and return unless logged_in?
        ical_schedule = @festival.to_ical(current_user.id) do |screening|
          @festival.external_film_url(screening.film) || poly_festival_url(@festival)
#          poly_film_screening_url(screening.film, screening, 
#                                  :host => request.host_with_port)  
        end
        render :text => ical_schedule
      end
    end
  end
  
  # POST /festivals/1/pick_screening
  def pick_screening
    render :update do |page|
      if logged_in?
        @festival = Festival.find_by_slug(params[:id])
        screening = Screening.find(params[:screening_id])
        state = (params[:state] || "picked").to_sym
        changed = screening.set_state(current_user, state)
        page << screening_settings_to_js(changed)
      end
    end
  end
  
  # POST /festivals/1/schedule
  def schedule
    # renders automatically, which does a client-side redirect to schedule_continue
    # as a progress indication.
    @festival = Festival.find_by_slug(params[:id])
  end
  
  # POST /festivals/1/schedule_continue
  def schedule_continue
    if logged_in?
      @festival = Festival.find_by_slug(params[:id])
      sched = AutoScheduler.new(current_user.id, @festival.id)
      begin
        scheduled_count = sched.go
        flash[:notice] = "#{scheduled_count} of your films #{scheduled_count == 1 ? "was" : "were"} scheduled for you."
      rescue AutoSchedulingError => e
        flash[:warning] = e.message
      end
    end
    redirect_to poly_festival_url(params[:id])
  end
  
  # GET /festivals/1/update_days
  def update_days
    # render_days
  end

  # POST /festivals/1/reset_rankings
  def reset_rankings
    @festival = Festival.find_by_slug(params[:id])
    @festival.reset_rankings(current_user) if logged_in?
    redirect_to poly_festival_films_url(@festival)
  end
    
  # POST /festivals/1/reset_screenings
  def reset_screenings
    @festival = Festival.find_by_slug(params[:id])
    @festival.reset_screenings(current_user) if logged_in?
    # render_days
  end
    
  # GET /festivals/new
  # GET /festivals/new.xml
  def new
    @festival = Festival.new
      
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @festival }
    end
  end

  # GET /festivals/1/edit
  def edit
    @festival = Festival.find_by_slug(params[:id], :include => [:venues, { :films => :screenings }])
  end

  # POST /festivals
  # POST /festivals.xml
  def create
    @festival = Festival.new(params[:festival])
    @festival.is_conference = conference_mode
    @saved = @festival.save
    
    respond_to do |format|
      if @saved
        flash[:notice] = 'Festival was successfully created.'
        format.html { redirect_to(poly_edit_festival_url(@festival)) }
        format.xml  { render :xml => @festival, :status => :created, :location => @festival }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @festival.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /festivals/1
  # PUT /festivals/1.xml
  def update
    @festival = Festival.find_by_slug(params[:id])

    respond_to do |format|
      if @festival.update_attributes(params[:festival])
        flash[:notice] = 'Festival was successfully updated.'
        format.html { redirect_to(@festival) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @festival.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /festivals/1
  # DELETE /festivals/1.xml
  def destroy
    @festival = Festival.find_by_slug(params[:id])
    @festival.destroy

    respond_to do |format|
      format.html { redirect_to(poly_festivals_url) }
      format.xml  { head :ok }
    end
  end

private
  def screening_settings_to_js(screenings=nil)
    screenings ||= @festival.screenings
    screening_by_screening_id = screenings.index_by(&:id)
    picks = Pick.find_all_by_user_id_and_festival_id(current_user, @festival)
    pick_by_screening_id = picks.index_by(&:screening_id)
    updated_screening_states = screening_by_screening_id.keys.group_by do |screening_id|
      s = screening_by_screening_id[screening_id]
      p = pick_by_screening_id[screening_id]
      if p.nil?
        ["unranked", "You haven't prioritized this film."]
      elsif p.screening_id == screening_id
        ["scheduled", "You're scheduled to see this screening."]
      elsif p.screening_id
        ["otherscheduled", "You're seeing this on #{screening_by_screening_id[p.screening_id].date_and_times}."]
      elsif p.priority.nil?
        ["unranked", "You haven't prioritized this film."]
      elsif p.priority > 0
        ["unscheduled", "You prioritized this, but no screening is selected."]
      else
        ["unranked", "You gave this the lowest priority."]
      end
    end
    
    # Make the javascript
    updated_screening_states.map do |state_and_tip, screening_ids|
      state, tooltip = state_and_tip
      %Q[jQuery("#{screening_ids.map {|id| "#screening-" + id.to_s}.join(",")}").attr("class", "screening #{state}").attr("title", "#{tooltip}");]
    end.join("\n")
  end

  def render_days
    # "Get me all the screenings in the festival; for each screening, get its 
    # film and venue too." -- whew!
    @festival = Festival.find_by_slug(params[:id], :include => { :screenings => [:venue, { :film => :screenings }] })
    
    # "If a user is logged in, give me all of this users' picks for this festival"
    @picks = logged_in? ? Pick.find_all_by_user_id_and_festival_id(current_user.id, @festival.id) : []
    
    render :action => "update_days"    
  end
end
