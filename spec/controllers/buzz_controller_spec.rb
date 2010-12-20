require File.dirname(__FILE__) + '/../spec_helper'

describe BuzzController do

  def mock_film
    @mock_film ||= begin
      film = mock_model(Film, :id => "1", :buzz => [])
      Film.stub(:find).with("1").and_return(film)
      film
    end
  end

  def mock_buzz(stubs={})
    @mock_buzz ||= mock_model(Buzz, stubs)
  end

  describe "GET index" do
    it "assigns all buzz as @buzz" do
      Buzz.stub(:find).with(:all).and_return([mock_buzz])
      get :index, :film_id => mock_film.id
      assigns[:buzz].should == [mock_buzz]
    end
  end

  describe "GET show" do
    it "assigns the requested buzz as @buzz" do
      Buzz.stub(:find).with("37").and_return(mock_buzz)
      get :show, :id => "37"
      assigns[:buzz].should equal(mock_buzz)
    end
  end

  describe "GET new" do
    it "assigns a new buzz as @buzz" do
      Buzz.stub(:new).and_return(mock_buzz)
      get :new, :film_id => mock_film.id
      assigns[:buzz].should equal(mock_buzz)
    end
  end

  describe "GET edit" do
    it "assigns the requested buzz as @buzz" do
      Buzz.stub(:find).with("37").and_return(mock_buzz)
      get :edit, :id => "37"
      assigns[:buzz].should equal(mock_buzz)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created buzz as @buzz" do
        Buzz.stub(:new).with({'these' => 'params'}).and_return(mock_buzz(:save => true))
        post :create, :film_id => mock_film.id, :buzz => {:these => 'params'}
        assigns[:buzz].should equal(mock_buzz)
      end

      it "redirects to the created buzz" do
        Buzz.stub(:new).and_return(mock_buzz(:save => true))
        post :create, :film_id => mock_film.id, :buzz => {}
        response.should redirect_to(buzz_url(mock_buzz))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved buzz as @buzz" do
        Buzz.stub(:new).with({'these' => 'params'}).and_return(mock_buzz(:save => false))
        post :create, :film_id => mock_film.id, :buzz => {:these => 'params'}
        assigns[:buzz].should equal(mock_buzz)
      end

      it "re-renders the 'new' template" do
        Buzz.stub(:new).and_return(mock_buzz(:save => false))
        post :create, :film_id => mock_film.id, :buzz => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested buzz" do
        Buzz.should_receive(:find).with("37").and_return(mock_buzz)
        mock_buzz.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :buzz => {:these => 'params'}
      end

      it "assigns the requested buzz as @buzz" do
        Buzz.stub(:find).and_return(mock_buzz(:update_attributes => true))
        put :update, :id => "1"
        assigns[:buzz].should equal(mock_buzz)
      end

      it "redirects to the buzz" do
        Buzz.stub(:find).and_return(mock_buzz(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(buzz_url(mock_buzz))
      end
    end

    describe "with invalid params" do
      it "updates the requested buzz" do
        Buzz.should_receive(:find).with("37").and_return(mock_buzz)
        mock_buzz.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :buzz => {:these => 'params'}
      end

      it "assigns the buzz as @buzz" do
        Buzz.stub(:find).and_return(mock_buzz(:update_attributes => false))
        put :update, :id => "1"
        assigns[:buzz].should equal(mock_buzz)
      end

      it "re-renders the 'edit' template" do
        Buzz.stub(:find).and_return(mock_buzz(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

#  describe "DELETE destroy" do
#    it "destroys the requested buzz" do
#      Buzz.should_receive(:find).with("37").and_return(mock_buzz)
#      mock_buzz.should_receive(:destroy)
#      delete :destroy, :id => "37"
#    end
#
#    it "redirects to the buzz list" do
#      Buzz.stub(:find).and_return(mock_buzz(:destroy => true))
#      delete :destroy, :id => "1"
#      response.should redirect_to(buzz_url)
#    end
#  end
end
