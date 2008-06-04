require File.dirname(__FILE__) + '/../spec_helper'

describe ScreeningsController do
  include AdminUserSpecHelper

  def make_film_and_screening
    @festival = mock_model(Festival, :public => true, :is_conference => false)
    @film = mock_model(Film, :to_param => "1", :festival => @festival)
    Film.stub!(:find).and_return(@film)
    @screening = mock_model(Screening, :to_param => "1", :festival => @festival, :starts => "now")
    @screening.stub!(:starts=).with(any_args)
    @screenings = [@screening]
    @screenings.stub!(:find).and_return(@screening)
    @film.stub!(:screenings).and_return(@screenings)
  end
  
  describe "in general," do
    before { make_film_and_screening }    
    require_admin_rights_appropriately :film_id => "1"
  end

  def do_get
    get :index, :film_id => "1"
  end

  describe "handling GET /films/1/screenings" do
    before { make_film_and_screening }
  
    it "should fail if ordinary html requested" do
      lambda {get :index, :film_id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end
#    
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
#    it "should find all screenings" do
#      @film.should_receive(:screenings).and_return(@screenings)
#      do_get
#    end
#  
#    it "should assign the found screenings for the view" do
#      do_get
#      assigns[:screenings].should == @screenings
#    end
  end

  describe "handling GET /films/1/screenings.xml" do

    before(:each) do
      make_film_and_screening
      @screening.stub!(:to_xml).and_return("XML")
      @screenings.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index, :film_id => "1"
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all screenings" do
      @film.should_receive(:screenings).and_return(@screenings)
      do_get
    end
  
    it "should render the found screenings as xml" do
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /films/1/screenings/1" do

    before(:each) do
      make_film_and_screening
    end
  
    def do_get
      get :show, :film_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :show, :film_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
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
#    it "should find the screening requested" do
#      @screenings.should_receive(:find).with(any_args).and_return(@screening)
#      do_get
#    end
#  
#    it "should assign the found screening for the view" do
#      do_get
#      assigns[:screening].should equal(@screening)
#    end
  end

  describe "handling GET /films/1/screenings/1.xml" do

    before(:each) do
      make_film_and_screening
      @screening.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :film_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the screening requested" do
      @screenings.should_receive(:find).with(any_args).and_return(@screening)
      do_get
    end
  
    it "should render the found screening as xml" do
      @screening.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /films/1/screenings/new" do

    before(:each) do
      login_as admin_user
      make_film_and_screening
      @screenings.stub!(:new).and_return(@screening)
    end
  
    def do_get
      get :new, :film_id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :new, :film_id => "1"}.should raise_error(NonAjaxEditsNotSupported)
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
#    it "should create an new screening" do
#      @screenings.should_receive(:new).and_return(@screening)
#      do_get
#    end
#  
#    it "should not save the new screening" do
#      @screening.should_not_receive(:save)
#      do_get
#    end
#  
#    it "should assign the new screening for the view" do
#      do_get
#      assigns[:screening].should equal(@screening)
#    end
  end

  describe "handling GET /films/1/screenings/1/edit" do

    before(:each) do
      login_as admin_user
      make_film_and_screening
    end

    def do_get
      get :edit, :film_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {get :edit, :film_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
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
#    it "should find the screening requested" do
#      @screenings.should_receive(:find).and_return(@screening)
#      do_get
#    end
#  
#    it "should assign the found Screening for the view" do
#      do_get
#      assigns[:screening].should equal(@screening)
#    end
  end

  describe "handling POST /films/1/screenings" do

    before(:each) do
      login_as admin_user
      make_film_and_screening
      @screenings.stub!(:new).and_return(@screening)
      @screening.stub!(:save)
    end

    it "should fail if ordinary html requested" do
      lambda {post :create, :film_id => "1", :screening => {}}.should raise_error(NonAjaxEditsNotSupported)
    end
    
#    describe "with successful save" do
#  
#      def do_post
#        @screening.should_receive(:save).and_return(true)
#        post :create, :film_id => "1", :screening => {}
#      end
#  
#      it "should create a new screening" do
#        @screenings.should_receive(:new).with({}).and_return(@screening)
#        do_post
#      end
#
#      it "should redirect to the new screening" do
#        do_post
#        response.should redirect_to(film_screening_url("1","1"))
#      end
#      
#    end
#    
#    describe "with failed save" do
#
#      def do_post
#        @screening.should_receive(:save).and_return(false)
#        post :create, :screening => {}
#      end
#  
#      it "should re-render 'new'" do
#        do_post
#        response.should render_template('new')
#      end
#      
#    end
  end

  describe "handling PUT /films/1/screenings/1" do

    before(:each) do
      login_as admin_user
      make_film_and_screening
      @screening.stub!(:update_attributes).and_return(true)
      @screenings.stub!(:new).and_return(@screening)
    end
    
    it "should fail if ordinary html requested" do
      lambda {put :update, :film_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end
#
#    describe "with successful update" do
#
#      def do_put
#        @screening.should_receive(:update_attributes).and_return(true)
#        put :update, :film_id => "1", :id => "1"
#      end
#
#      it "should find the screening requested" do
#        @screenings.should_receive(:find).with("1").and_return(@screening)
#        do_put
#      end
#
#      it "should update the found screening" do
#        do_put
#        assigns(:screening).should equal(@screening)
#      end
#
#      it "should assign the found screening for the view" do
#        do_put
#        assigns(:screening).should equal(@screening)
#      end
#
#      it "should redirect to the screening" do
#        do_put
#        response.should redirect_to(film_screening_url("1", "1"))
#      end
#
#    end
#    
#    describe "with failed update" do
#
#      def do_put
#        @screening.should_receive(:update_attributes).and_return(false)
#        put :update, :film_id => "1", :id => "1"
#      end
#
#      it "should re-render 'edit'" do
#        do_put
#        response.should render_template('edit')
#      end
#
#    end
  end

  describe "handling DELETE /screenings/1" do

    before(:each) do
      login_as admin_user
      make_film_and_screening
      @screening.stub!(:destroy).and_return(true)
    end
  
    def do_delete
      delete :destroy, :film_id => "1", :id => "1"
    end

    it "should fail if ordinary html requested" do
      lambda {delete :destroy, :film_id => "1", :id => "1"}.should raise_error(NonAjaxEditsNotSupported)
    end

#    it "should find the screening requested" do
#      @screenings.should_receive(:find).with("1").and_return(@screening)
#      do_delete
#    end
#  
#    it "should call destroy on the found screening" do
#      @screening.should_receive(:destroy)
#      do_delete
#    end
#  
#    it "should redirect to the screenings list" do
#      do_delete
#      response.should redirect_to(film_screenings_url(@film))
#    end
  end
end
