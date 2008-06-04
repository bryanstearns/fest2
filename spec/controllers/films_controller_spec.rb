require File.dirname(__FILE__) + '/../spec_helper'

describe FilmsController do
  include AdminUserSpecHelper
  
  def make_festival_and_film
    @festival = mock_model(Festival, :public => true, :to_param => "1", :is_conference => false)
    @film = mock_model(Film, :to_param => "1")
    @films = [@film]
    @films.stub!(:find).and_return(@film)
    Festival.stub!(:find_by_slug).and_return(@festival)
    @festival.stub!(:films).and_return(@films)
  end
  
  describe "in general," do
    before { make_festival_and_film }    
    require_admin_rights_appropriately :festival_id => "1"
  end

  describe "handling GET /festivals/1/films" do
    
    before(:each) { make_festival_and_film }
  
    def do_get
      get :index, :festival_id => 1
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all films" do
      @festival.should_receive(:films).and_return([@film])
      do_get
    end
  
    it "should assign the found films for the view" do
      do_get
      assigns[:films].should == [@film]
    end
    
    it "should not find picks if not logged in" do
      logout
      do_get
      assigns[:picks].should == {}
    end
    
    it "should find picks if logged in" do
      login_as ordinary_user
      @pick = mock_model(Pick, :film_id => 2)
      Pick.stub!(:find_all_by_festival_id_and_user_id).and_return([@pick])
      do_get
      assigns[:picks].should == { 2 => @pick }
    end
  end

  describe "handling GET /festivals/1/films.xml" do

    before(:each) do
      make_festival_and_film
      @film.stub!(:to_xml).and_return("XML")
      @films.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index, :festival_id => 1
   end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all films" do
      @festival.should_receive(:films).and_return([@film])
      do_get
    end
  
    it "should render the found films as xml" do
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1/films/1" do

    before(:each) do
      make_festival_and_film
    end
  
    def do_get
      get :show, :festival_id => 1, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the film requested" do
      @films.should_receive(:find).with("1").and_return(@film)
      do_get
    end
  
    it "should assign the found film for the view" do
      do_get
      assigns[:film].should equal(@film)
    end
  end

  describe "handling GET /festivals/1/films/1.xml" do

    before(:each) do
      make_festival_and_film
      @film.stub!(:to_xml).and_return("XML")
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :festival_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the film requested" do
      @films.should_receive(:find).with("1").and_return(@film)
      do_get
    end
  
    it "should render the found film as xml" do
      @film.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /festivals/1/films/new" do

    before(:each) do
      login_as admin_user
      make_festival_and_film
      @films.stub!(:new).and_return(@film)
    end

    def do_get
      get :new, :festival_id => 1
    end
    
    it "should fail if ordinary html requested" do
      lambda {get :new, :festival_id => 1}.should raise_error(NonAjaxEditsNotSupported)
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
#    it "should create an new film" do
#      @films.should_receive(:new).and_return(@film)
#      do_get
#    end
#  
#    it "should not save the new film" do
#      @film.should_not_receive(:save)
#      do_get
#    end
#  
#    it "should assign the new film for the view" do
#      do_get
#      assigns[:film].should equal(@film)
#    end
  end

  describe "handling GET /festivals/1/films/1/edit" do

    before(:each) do
      login_as admin_user
      make_festival_and_film
    end
  
    def do_get
      get :edit, :festival_id => "1", :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the film requested" do
      @films.should_receive(:find).and_return(@film)
      do_get
    end
  
    it "should assign the found Film for the view" do
      do_get
      assigns[:film].should equal(@film)
    end
  end

  describe "handling POST /festivals/1/films" do

    before(:each) do
      login_as admin_user
      make_festival_and_film
      @films.stub!(:new).and_return(@film)      
      @film.stub!(:save).and_return(true)
    end
    
    it "should fail if ordinary html requested" do
      lambda {post :create, :film => {}, :festival_id => 1}.should raise_error(NonAjaxEditsNotSupported)
    end

#    describe "with successful save" do
#  
#      def do_post
#        @film.should_receive(:save).and_return(true)
#        post :create, :film => {}, :festival_id => "1"
#      end
#  
#      it "should create a new film" do
#        @films.should_receive(:new).with({}).and_return(@film)
#        do_post
#      end
#
#      it "should redirect to the new film" do
#        do_post
#        response.should redirect_to(festival_film_url("1","1"))
#      end
#      
#    end
#    
#    describe "with failed save" do
#
#      def do_post
#        @film.should_receive(:save).and_return(false)
#        post :create, :film => {}
#      end
#  
#      it "should re-render 'new'" do
#        do_post
#        response.should render_template('new')
#      end
#      
#    end
  end

  describe "handling PUT /festivals/1/films/1" do

    before(:each) do
      login_as admin_user
      make_festival_and_film
      @film.stub!(:update_attributes).and_return(true)
    end
    
    it "should fail if ordinary html requested" do
      lambda {put :update, :id => "1", :festival_id => 1}.should raise_error(NonAjaxEditsNotSupported)
    end

#    describe "with successful update" do
#
#      def do_put
#        @film.should_receive(:update_attributes).and_return(true)
#        put :update, :id => "1", :festival_id => "1"
#      end
#
#      it "should find the film requested" do
#        @films.should_receive(:find).with("1").and_return(@film)
#        do_put
#      end
#
#      it "should update the found film" do
#        do_put
#        assigns(:film).should equal(@film)
#      end
#
#      it "should assign the found film for the view" do
#        do_put
#        assigns(:film).should equal(@film)
#      end
#
#      it "should redirect to the film" do
#        do_put
#        response.should redirect_to(festival_film_url("1", "1"))
#      end
#
#    end
#    
#    describe "with failed update" do
#
#      def do_put
#        @film.should_receive(:update_attributes).and_return(false)
#        put :update, :id => "1"
#      end
#
#      it "should re-render 'edit'" do
#        do_put
#        response.should render_template('edit')
#      end
#
#    end
  end
end
