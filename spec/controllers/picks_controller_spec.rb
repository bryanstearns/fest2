require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../helpers/festival_film_spec_helper'

describe PicksController do
  include AdminUserSpecHelper
  include FestivalFilmSpecHelper

  def make_pick
    login_as ordinary_user
    
    @festival = mock_model(Festival, :public => true)
    @film = mock_model(Film, :to_param => "1", :festival => @festival)
    Film.stub!(:find).and_return(@film)
    @pick = mock_model(Pick, :to_param => "1", :festival => @festival, 
                       :film => @film, :user => @user)
    @picks = [@pick]
    @user.stub!(:picks).and_return(@picks)
    @picks.stub!(:find_by_film_id).and_return(@pick)
  end

  describe "handling GET /festivals/1/priorities" do
    before(:each) do
      login_as ordinary_user
      make_festival_and_film
    end

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

  describe "handling GET /festivals/1/priorities.xml" do

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

  describe "handling POST /picks" do

    before(:each) { make_pick }
    
    describe "with successful save" do
  
      def do_post
        @pick.should_receive(:update_attributes).and_return(true)
        post :create, :pick => {}, :film_id => @film.id
      end
  
      it "should find or create a new pick" do
        @picks.should_receive(:find_by_film_id).and_return(@pick)
        do_post
      end      
    end
    
    describe "with failed save" do

      def do_post
        @pick.should_receive(:update_attributes).and_return(false)
        post :create, :pick => {}, :film_id => @film.id
      end
  
#      it "should re-render 'new'" do
#        do_post
#        response.should render_template('new')
#      end
      
    end
  end
end
