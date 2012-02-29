class FestivalsController < ApplicationController
  before_filter :require_admin_subscription, :except => \
    [:index, :show, :pick_screening, :ratings, :reset_rankings,
     :reset_screenings]
  before_filter :load_festival, :only => \
    [:show, :pick_screening, :ratings, :reset_rankings,
     :reset_screenings, :statistics]

  # GET /festivals
  def index
    @festival_groups = festivals_grouped(Festival.send(find_scope)) || raise(ActiveRecord::RecordNotFound)
  end

  # GET /festivals/x_2009
  # GET /festivals/x_2009.xml
  # GET /festivals/x_2009.ics
  # GET /festivals/x_2009/stearns/sekrit
  # GET /festivals/x_2009/stearns/sekrit.xml
  # GET /festivals/x_2009/stearns/sekrit.rss
  def show
    if params.delete(:landing)
      if logged_in?
        if current_user.has_screenings_for(@festival)
          Journal.landing_on_schedule(:festival => @festival)
          redirect_to festival_url(@festival) and return
        end
        if current_user.has_rankings_for(@festival)
          Journal.landing_on_assistant(:festival => @festival)
          redirect_to festival_assistant_url(@festival) and return
        end
      end
      Journal.landing_on_priorities(:festival => @festival)
      redirect_to festival_priorities_url(@festival) and return
    end

    if params[:other_user_id]
      username = User.from_param(params[:other_user_id])
      @displaying_user = User.find_by_username(username)
      raise ActiveRecord::RecordNotFound unless @displaying_user
      @displaying_user_subscription = @displaying_user.subscription_for(@festival, :create => true)
      raise ActiveRecord::RecordNotFound unless @displaying_user_subscription \
        and @displaying_user_subscription.key == params[:key]
      Journal.viewing_user_schedule(:festival => @festival,
                                    :format => request.format.try(:to_sym),
                                    :subject => @displaying_user)
      @read_only = true
    else
      Journal.viewing_schedule(:festival => @festival, :format => request.format.try(:to_sym))
      @read_only, @displaying_user, @displaying_user_subscription = \
        [false, current_user, current_user.subscription_for(@festival, :create => true)] \
        if logged_in?
    end
      
    @show_press = params[:with_press] \
      ? (params[:with_press] == "1") \
      : (@displaying_user_subscription.show_press rescue false)
    @cache_key = @festival.cache_key(@show_press)

    filename = [@festival.slug, 
                (@displaying_user.to_param rescue nil), 
                params[:format]].compact.join(".")
    
    respond_to do |format|
      format.html do
        if params[:debug]
          @sched_debug = AutoScheduler.new(current_user, @festival)
          @sched_debug.collect_screenings_by_cost
          FestivalsHelper::ViewingInfo.sched_debug = @sched_debug
        end
        @screening_javascript = screening_settings_to_js(@displaying_user)
        # show.html.erb
      end
      format.xml do
        xml_schedule = @festival.to_xml
        send_data(xml_schedule, :filename => filename,
                  :type => "application/xml")
      end
      # format.mobile # show.mobile.erb
      format.pdf do
        @picks = @displaying_user ? @displaying_user.picks.find_all_by_festival_id(@festival.id) : []
        prawnto :prawn => { :skip_page_creation => true },
                :filename => filename
      end
      format.ics do
        redirect_to login_url and return unless @displaying_user
        ics_schedule = @festival.to_ics(@displaying_user.id) do |screening|
          (@festival.external_film_url(screening.film) ||
           film_screening_url(screening.film, screening,
                              :host => request.host_with_port))
        end
        send_data(ics_schedule, :filename => filename, :type => :ics)
      end
      format.csv do 
        csv_schedule = @festival.to_csv
        send_data(csv_schedule, :filename => filename, :type => :csv)
      end
    end
  end

  # GET /festivals/x_2009/stearns/ratings
  def ratings
    username = User.from_param(params[:other_user_id])
    @displaying_user = User.find_by_username(username)
    raise ActiveRecord::RecordNotFound unless @displaying_user
    @rated_picks = @festival.picks.for_user(@displaying_user).rated
    Journal.viewing_user_ratings(:festival => @festival,
                                 :subject => @displaying_user)
  end

  # GET /festivals/x_2009/statistics
  def statistics
    respond_to do |format|
      format.html do
        @statistics = @festival.statistics
      end
      format.csv do
        csv_data = FasterCSV.generate do |csv|
          @festival.user_ratings_by_film.each do |row|
            csv << row
          end
        end
        send_data(csv_data, :filename => "#{@festival.slug}.csv",
                  :type => :csv)
      end
    end
    Journal.viewing_statistics(:festival => @festival)
  end

  # POST /festivals/1/pick_screening
  def pick_screening
    js = if logged_in?
      screening = Screening.find(params[:screening_id])
      state = (params[:state] || "picked").to_sym
      Journal.screening_picked(:festival => @festival,
                               :subject => screening,
                               :state => state)
      changed = screening.set_state(current_user, state)
      screening_settings_to_js(current_user, changed)
    else
      ""
    end
    respond_to do |format|
      format.html do
        redirect_to festival_url(@festival, :debug => params[:debug]) and return
      end
      format.js do
        render :update do |page| page << js end
      end
    end
  end
  
  # POST /festivals/1/reset_rankings
  def reset_rankings
    if logged_in?
      Journal.reset_rankings(:festival => @festival)
      @festival.reset_rankings(current_user)
    end
    redirect_to festival_priorities_url(@festival)
  end
    
  # POST /festivals/1/reset_screenings
  def reset_screenings
    if logged_in?
      Journal.reset_screenings(:festival => @festival)
      @festival.reset_screenings(current_user)
    end
    redirect_to festival_url(@festival)
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
    @festival = Festival.find_by_slug!(params[:id])
  end

  # POST /festivals
  # POST /festivals.xml
  def create
    @festival = Festival.new(params[:festival])
    @saved = @festival.save
    
    respond_to do |format|
      if @saved
        flash[:notice] = 'Festival was successfully created.'
        format.html { redirect_to(edit_festival_url(@festival)) }
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
    @festival = Festival.find_by_slug!(params[:id])

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
    @festival = Festival.find_by_slug!(params[:id])
    @festival.destroy

    respond_to do |format|
      format.html { redirect_to(festivals_url) }
      format.xml  { head :ok }
    end
  end

private
  def load_festival
    @festival = Festival.find_by_slug!(params[:festival_id] || params[:id])
    check_festival_access
    cookies[:festival] = { :value => @festival.slug,
                           :expires => 10.years.from_now }
  end

  def screening_settings_to_js(for_user, screenings=nil)
    return "" unless for_user
    screenings ||= @festival.screenings
    screening_by_screening_id = screenings.index_by(&:id)
    picks = Pick.find_all_by_user_id_and_festival_id(for_user, @festival)
    pick_by_film_id = picks.index_by(&:film_id)

    # Make the javascript to update the states and insert the priority symbols
    updated_screening_states = screening_by_screening_id.keys.group_by do |screening_id|
      s = screening_by_screening_id[screening_id]
      p = pick_by_film_id[s.film_id]
      if p
        if p.screening_id == screening_id
          "scheduled"
        elsif p.screening_id
          "otherscheduled"
        elsif p.priority.nil?
          "unranked"
        elsif p.priority > 0
          "unscheduled"
        else
          "lowprio"
        end
      else
        "unranked"
      end
    end
    js = updated_screening_states.map do |state, screening_ids|
      %Q[jQuery("#{screening_ids.map {|id| "#screening-" + id.to_s}.join(",")}").attr("class", "screening #{state}");]
    end.join("\n")

    screenings_by_priority_or_rating = screenings.group_by do |s|
      p = pick_by_film_id[s.film_id]
      if p.try(:rating)
        -p.rating
      elsif p.try(:priority)
        p.priority
      else
        nil
      end
    end
    js += screenings_by_priority_or_rating.map do |priority_or_rating, screenings|
      unless priority_or_rating.nil?
        id_list = screenings.map {|s| "#screening-" + s.id.to_s}.join(",")
        content = if priority_or_rating < 0 # it's -stars
          view_helper.image_tag("priority/star.png",
                                :height => 10, :width => 10) * -priority_or_rating
        else
          view_helper.image_tag("priority/p#{priority_or_rating}.png",
                                :height => 10, :width => 46)
        end
        %Q[jQuery("#{id_list}").find('.priority').html('#{content}');]
      end
    end.join("\n")

    js += %Q[jQuery(".revised span").html("#{view_helper.festival_revision_info(@festival, picks)}");]
    js
  end

  def festivals_grouped(festivals)
    # Group these festivals by their slug_group, with the groups
    # in alphabetical order by the name of the most-recent festival,
    # and the individual group entries sorted by time, reversed, eg:
    # [ [Afest 2010, Afest 2009],
    #   [Bfest 2007],
    #   [Cfest 2009, Cfest 2008] ]
    groups = festivals.group_by(&:slug_group)
    groups.map do |slug_group, festivals|
      festivals.sort_by {|festival| -festival.starts.jd }
    end.sort_by {|group| group.first.starts }.reverse
  end
end
