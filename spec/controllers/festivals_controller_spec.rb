require File.dirname(__FILE__) + '/../spec_helper'

describe FestivalsController do
  include AdminUserSpecHelper
  
  def make_festival
    venues = []
    @festival = mock_model(Festival, :venues => venues, :public => true,
                           :is_conference => false, :updated_at => Time.zone.now - 1.day)
    @festival.stub!(:to_ical).and_return("ICAL")
    @festival.stub!(:to_xml).and_return("XML")
    @festivals = [@festival]
    @festivals.stub!(:to_xml).and_return("XML")
    
    # For now, while we're auto-creating dummy venues
    venues.stub!(:create).and_return(nil)
    
    Festival.stub!(:new).and_return(@festival)
    Festival.stub!(:find_by_slug).and_return(@festival)
    Festival.stub!(:festivals).and_return(@festivals)
  end
  
  describe "in general," do
  
    before { make_festival }    
    require_admin_rights_appropriately
  end

  describe "handling GET /festivals" do
    before { make_festival }    
    
    def do_get
      get :index
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render index template" do
      do_get
      response.should render_template('index')
    end
    
    it "should find all public festivals" do
      Festival.should_receive(:festivals).and_return([@festival])
      do_get
    end
    
    it "should assign the found festivals for the view" do
      do_get
      assigns[:festivals].should == [@festival]
    end
  end

  describe "handling GET /festivals.xml" do
    before do
      make_festival
      @festival.stub!(:to_xml).and_return("XML")
    end
    
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find all festivals" do
      Festival.should_receive(:festivals).and_return(@festivals)
      do_get
    end
    
    it "should render the found festivals as xml" do
      @festivals.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1" do
  
    before { make_festival }    
    
    def do_get
      get :show, :id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
    
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).and_return(@festival)
      do_get
    end
    
    it "should assign the found festival for the view" do
      do_get
      assigns[:festival].should equal(@festival)
    end
  end

  describe "handling GET /festivals/1.xml" do
  
    before do
      make_festival
      @festival.stub!(:to_xml).and_return("XML")
    end
    
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).and_return(@festival)
      do_get
    end
    
    it "should render the found festival as xml" do
      @festival.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1.ical" do
  
    before do
      make_festival
    end
    
    def do_get_as(user)
      login_as user unless user.nil?
      @request.env["HTTP_ACCEPT"] = "text/icalendar"
      get :show, :id => "1"
    end
  
    it "should be successful when logged in" do
      do_get_as ordinary_user
      response.should be_success
    end
    
    it "should redirect to login page if not logged in" do
      do_get_as nil
      response.should redirect_to(login_url)
    end
    
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).and_return(@festival)
      do_get_as ordinary_user
    end
    
    it "should render the found festival as ical" do
      #@festival.should_receive(:to_ical).with(any_args).and_return("ICAL")
      do_get_as ordinary_user
      response.body.should == "ICAL"
    end
  end

  describe "handling GET /festivals/new" do  
    before do
      login_as admin_user
      make_festival
    end
    
    def do_get
      get :new
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
    
    it "should create an new festival" do
      Festival.should_receive(:new).and_return(@festival)
      do_get
    end
    
    it "should not save the new festival" do
      @festival.should_not_receive(:save)
      do_get
    end
    
    it "should assign the new festival for the view" do
      do_get
      assigns[:festival].should equal(@festival)
    end
  end

  describe "handling GET /festivals/1/edit" do
  
    before do
      login_as admin_user
      make_festival
    end
    
    def do_get
      get :edit, :id => "1"
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
    
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).and_return(@festival)
      do_get
    end
    
    it "should assign the found Festival for the view" do
      do_get
      assigns[:festival].should equal(@festival)
    end
  end

  describe "handling POST /festivals" do
    
    before do
      login_as admin_user
      make_festival
      @festival.stub!(:is_conference=)
      @festival.stub!(:to_param).and_return("1")
    end
    
    def post_with_successful_save
      @festival.should_receive(:save).and_return(true)
      post :create, :festival => {}    
    end
    
    def post_with_failed_save
      @festival.should_receive(:save).and_return(false)
      post :create, :festival => {}    
    end
      
    it "should create a new festival" do
      Festival.should_receive(:new).with({}).and_return(@festival)
      post_with_successful_save
    end
  
    it "should redirect to edit the new festival on successful save" do
      post_with_successful_save
      response.should redirect_to(edit_festival_url("1"))
    end
  
    it "should re-render 'new' on failed save" do
      post_with_failed_save
      response.should render_template('new')
    end
  end

  describe "handling PUT /festivals/1" do
    
    before do
      login_as admin_user
      @festival = mock_model(Festival, :to_param => "1")
      Festival.stub!(:find_by_slug).and_return(@festival)
    end
  
    def put_with_successful_update
      @festival.should_receive(:update_attributes).and_return(true)
      put :update, :id => "1"
    end
    
    def put_with_failed_update
      @festival.should_receive(:update_attributes).and_return(false)
      put :update, :id => "1"
    end
    
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).with("1").and_return(@festival)
      put_with_successful_update
    end
  
    it "should update the found festival" do
      put_with_successful_update
      assigns(:festival).should equal(@festival)
    end
  
    it "should assign the found festival for the view" do
      put_with_successful_update
      assigns(:festival).should equal(@festival)
    end
  
    it "should redirect to the festival on successful update" do
      put_with_successful_update
      response.should redirect_to(festival_url("1"))
    end
  
    it "should re-render 'edit' on failed update" do
      put_with_failed_update
      response.should render_template('edit')
    end
  end

  describe "handling DELETE /festivals/1" do
    before do
      login_as admin_user
      @festival = mock_model(Festival, :destroy => true)
      Festival.stub!(:find_by_slug).and_return(@festival)
    end
    
    def do_destroy
      delete :destroy, :id => "1"
    end
  
    it "should find the festival requested" do
      Festival.should_receive(:find_by_slug).with("1").and_return(@festival)
      do_destroy
    end
    
    it "should call destroy on the found festival" do
      @festival.should_receive(:destroy)
      do_destroy
    end
    
    it "should redirect to the festivals list" do
      do_destroy
      response.should redirect_to(festivals_url)
    end
  end
end
