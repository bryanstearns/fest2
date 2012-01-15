require File.dirname(__FILE__) + '/../spec_helper'

describe VenuesController do
  include AdminUserSpecHelper

  def make_venue
    @festival = mock_model(Festival, :public => true, :to_param => "1")
    Festival.stub!(:find_by_slug!).and_return(@festival)
    @venue = mock_model(Venue, :to_param => "1", :festival => @festival)
    @venues = [@venue]
    @venues.stub!(:find).and_return(@venue)
    @festival.stub!(:venues).and_return(@venues)
  end

  describe "in general," do
    before { make_venue }    
    require_admin_rights_appropriately :festival_id => "1"
  end

=begin
  def do_get
    get :index, :festival_id => "1"
  end
  
  describe "handling GET /festivals/1/venues" do
    before { make_venue }    

    it "should fail if ordinary html requested" do
      lambda {get :index, :festival_id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#
#    it "should render index template" do
#      do_get
#      response.should render_template('index')
#    end
#  
#    it "should find all venues" do
#      Venue.should_receive(:find).with(:all).and_return([@venue])
#      do_get
#    end
#  
#    it "should assign the found venues for the view" do
#      do_get
#      assigns[:venues].should == [@venue]
#    end
  end

  describe "handling GET /festivals/1/venues.xml" do

    before(:each) do
      make_venue
      @venues.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index, :festival_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all venues" do
      @festival.should_receive(:venues).and_return(@venues)
      do_get
    end
  
    it "should render the found venues as xml" do
      @venues.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1/venues/1" do
    before { make_venue }    
  
    def do_get
      get :show, :festival_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :show, :festival_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#  
#    it "should render show template" do
#      do_get
#      response.should render_template('show')
#    end
#  
#    it "should find the venue requested" do
#      Venue.should_receive(:find).with("1").and_return(@venue)
#      do_get
#    end
#  
#    it "should assign the found venue for the view" do
#      do_get
#      assigns[:venue].should equal(@venue)
#    end
  end

  describe "handling GET /festivals/1/venues/1.xml" do

    before(:each) do
      make_venue
      @venue.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :festival_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the venue requested" do
      @festival.should_receive(:venues).and_return(@venues)
      @venues.should_receive(:find).with("1").and_return(@venue)
      do_get
    end
  
    it "should render the found venue as xml" do
      @venue.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1/venues/new" do

    before(:each) do
      login_as admin_user
      make_venue
      @venues.stub!(:new).and_return(@venue)
    end
  
    def do_get
      get :new, :festival_id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :new, :festival_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#  
#    it "should render new template" do
#      do_get
#      response.should render_template('new')
#    end
#  
#    it "should create an new venue" do
#      Venue.should_receive(:new).and_return(@venue)
#      do_get
#    end
#  
#    it "should not save the new venue" do
#      @venue.should_not_receive(:save)
#      do_get
#    end
#  
#    it "should assign the new venue for the view" do
#      do_get
#      assigns[:venue].should equal(@venue)
#    end
  end

  describe "handling GET /festivals/1/venues/1/edit" do

    before(:each) do
      login_as admin_user
      make_venue
    end
  
    def do_get
      get :edit, :festival_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :edit, :festival_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should be successful" do
#      do_get
#      response.should be_success
#    end
#  
#    it "should render edit template" do
#      do_get
#      response.should render_template('edit')
#    end
#  
#    it "should find the venue requested" do
#      Venue.should_receive(:find).and_return(@venue)
#      do_get
#    end
#  
#    it "should assign the found Venue for the view" do
#      do_get
#      assigns[:venue].should equal(@venue)
#    end
  end

  describe "handling POST /festivals/1/venues" do

    before(:each) do
      login_as admin_user
      make_venue
      @venues.stub!(:new).and_return(@venue)
      @venue.stub!(:save).and_return(true)
    end
    
    it "should fail if ordinary html requested" do
      lambda {get :create, :festival_id => "1", :venue => {}}.should raise_error(NonAjaxEditsNotSupported)
    end

#    describe "with successful save" do
#  
#      def do_post
#        @venue.should_receive(:save).and_return(true)
#        post :create, :festival_id => "1", :venue => {}
#      end
#  
#      it "should create a new venue" do
#        Venue.should_receive(:new).with({}).and_return(@venue)
#        do_post
#      end
#
#      it "should redirect to the new venue" do
#        do_post
#        response.should redirect_to(venue_url("1"))
#      end
#      
#    end
#    
#    describe "with failed save" do
#
#      def do_post
#        @venue.should_receive(:save).and_return(false)
#        post :create, :festival_id => "1", :venue => {}
#      end
#  
#      it "should re-render 'new'" do
#        do_post
#        response.should render_template('new')
#      end
#      
#    end
  end

  describe "handling PUT /festivals/1/venues/1" do

    before(:each) do
      login_as admin_user
      make_venue
    end
    
    it "should fail if ordinary html requested" do
      @venue.stub!(:update_attributes).and_return(true)
      lambda {put :update, :festival_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    describe "with successful update" do
#
#      def do_put
#        @venue.should_receive(:update_attributes).and_return(true)
#        put :update, :festival_id => "1", :id => "1"
#      end
#
#      it "should find the venue requested" do
#        Venue.should_receive(:find).with("1").and_return(@venue)
#        do_put
#      end
#
#      it "should update the found venue" do
#        do_put
#        assigns(:venue).should equal(@venue)
#      end
#
#      it "should assign the found venue for the view" do
#        do_put
#        assigns(:venue).should equal(@venue)
#      end
#
#      it "should redirect to the venue" do
#        do_put
#        response.should redirect_to(venue_url("1"))
#      end
#
#    end
#    
#    describe "with failed update" do
#
#      def do_put
#        @venue.should_receive(:update_attributes).and_return(false)
#        put :update, :festival_id => "1", :id => "1"
#      end
#
#      it "should re-render 'edit'" do
#        do_put
#        response.should render_template('edit')
#      end
#
#    end
  end

  describe "handling DELETE /festivals/1/venues/1" do

    before(:each) do
      login_as admin_user
      make_venue
      @venue.stub!(:destroy).and_return(true)
    end
  
    def do_delete
      delete :destroy, :festival_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {delete :destroy, :festival_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should find the venue requested" do
#      Venue.should_receive(:find).with("1").and_return(@venue)
#      do_delete
#    end
#  
#    it "should call destroy on the found venue" do
#      @venue.should_receive(:destroy)
#      do_delete
#    end
#  
#    it "should redirect to the venues list" do
#      do_delete
#      response.should redirect_to(venues_url)
#    end
  end
=end
end
