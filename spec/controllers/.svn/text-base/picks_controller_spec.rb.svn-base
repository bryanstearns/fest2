require File.dirname(__FILE__) + '/../spec_helper'

describe PicksController do
  include AdminUserSpecHelper

  def make_pick
    login_as ordinary_user
    
    @festival = mock_model(Festival, :public => true, :is_festival => true,
                           :is_conference => false)
    @film = mock_model(Film, :to_param => "1", :festival => @festival)
    Film.stub!(:find).and_return(@film)
    @pick = mock_model(Pick, :to_param => "1", :festival => @festival, 
                       :film => @film, :user => @user)
    @picks = [@pick]
    @user.stub!(:picks).and_return(@picks)
    @picks.stub!(:find_or_initialize_by_film_id).and_return(@pick)
  end
  
  describe "handling POST /picks" do

    before(:each) { make_pick }
    
    describe "with successful save" do
  
      def do_post
        @pick.should_receive(:update_attributes).and_return(true)
        post :create, :pick => {}, :film_id => @film.id
      end
  
      it "should find or create a new pick" do
        @picks.should_receive(:find_or_initialize_by_film_id).and_return(@pick)
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