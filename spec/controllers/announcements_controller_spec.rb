require File.dirname(__FILE__) + '/../spec_helper'

describe AnnouncementsController do
  include AdminUserSpecHelper
  
  def make_announcement
      @announcement = mock_model(Announcement, :published => true, 
        :to_param => "1", :for_festival => true, :for_conference => true)
      @announcements = [@announcement]
      Announcement.stub!(:find_festivals).and_return(@announcement)
  end
  
  def make_announcements
      @announcements = [@announcement]
      Announcement.stub!(:find_festivals).and_return(@announcements)
  end
  
  describe "handling GET /announcements" do

    before(:each) do
      make_announcements
    end
  
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
  
    it "should find all published announcements" do
      Announcement.should_receive(:find_festivals).and_return(@announcements)
      do_get
    end
  
    it "should assign the found announcements for the view" do
      do_get
      assigns[:announcements].should == @announcements
    end
  end

  describe "handling GET /announcements.xml" do

    before(:each) do
      make_announcements
      @announcement.stub!(:to_xml).and_return("XML")
      @announcements.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all published announcements" do
      Announcement.should_receive(:find_festivals).and_return(@announcements)
      do_get
    end
  
    it "should render the found announcements as xml" do
      @announcements.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /announcements/1" do

    before(:each) do
      make_announcement
    end
  
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
  
    it "should find the announcement requested" do
      Announcement.should_receive(:find_festivals).with("1").and_return(@announcement)
      do_get
    end
  
    it "should assign the found announcement for the view" do
      do_get
      assigns[:announcement].should equal(@announcement)
    end
  end

  describe "handling GET /announcements/1.xml" do

    before(:each) do
      make_announcement
      @announcement.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the announcement requested" do
      Announcement.should_receive(:find_festivals).with("1").and_return(@announcement)
      do_get
    end
  
    it "should render the found announcement as xml" do
      @announcement.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /announcements/new" do

    before(:each) do
      login_as admin_user
      @announcement = mock_model(Announcement, :for_festival =>true, 
        :for_conference => false)
      Announcement.stub!(:new).and_return(@announcement)
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
  
    it "should create an new announcement" do
      Announcement.should_receive(:new).and_return(@announcement)
      do_get
    end
  
    it "should create the right flavor of announcement" do
      do_get
      @announcement.for_festival.should == true
      @announcement.for_conference.should == false
    end
  
    it "should not save the new announcement" do
      @announcement.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new announcement for the view" do
      do_get
      assigns[:announcement].should equal(@announcement)
    end
  end

  describe "handling GET /announcements/1/edit" do

    before(:each) do
      login_as admin_user
      make_announcement
      Announcement.stub!(:find).and_return(@announcement)
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
  
    it "should find the announcement requested" do
      Announcement.should_receive(:find).with("1").and_return(@announcement)
      do_get
    end
  
    it "should assign the found Announcement for the view" do
      do_get
      assigns[:announcement].should equal(@announcement)
    end
  end

  describe "handling POST /announcements" do

    before(:each) do
      login_as admin_user
      make_announcement
      Announcement.stub!(:new).and_return(@announcement)
    end
    
    describe "with successful save" do
  
      def do_post
        @announcement.should_receive(:save).and_return(true)
        post :create, :announcement => {}
      end
  
      it "should create a new announcement" do
        Announcement.should_receive(:new).with({}).and_return(@announcement)
        do_post
      end

      it "should redirect to the new announcement" do
        do_post
        response.should redirect_to(announcement_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @announcement.should_receive(:save).and_return(false)
        post :create, :announcement => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /announcements/1" do

    before(:each) do
      login_as admin_user
      @announcement = mock_model(Announcement, :to_param => "1")
      Announcement.stub!(:find).and_return(@announcement)
    end
    
    describe "with successful update" do

      def do_put
        @announcement.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the announcement requested" do
        Announcement.should_receive(:find).with("1").and_return(@announcement)
        do_put
      end

      it "should update the found announcement" do
        do_put
        assigns(:announcement).should equal(@announcement)
      end

      it "should assign the found announcement for the view" do
        do_put
        assigns(:announcement).should equal(@announcement)
      end

      it "should redirect to the announcement" do
        do_put
        response.should redirect_to(announcement_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @announcement.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /announcements/1" do

    before(:each) do
      login_as admin_user
      @announcement = mock_model(Announcement, :destroy => true)
      Announcement.stub!(:find).and_return(@announcement)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the announcement requested" do
      Announcement.should_receive(:find).with("1").and_return(@announcement)
      do_delete
    end
  
    it "should call destroy on the found announcement" do
      @announcement.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the announcements list" do
      do_delete
      response.should redirect_to(announcements_url)
    end
  end
end