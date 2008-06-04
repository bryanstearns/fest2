require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AdminController do
  describe "handling GET /admin" do
    def do_get_with_user(user)
      controller.should_receive(:current_user).any_number_of_times.\
        and_return(user)
      get :index
    end
  
    it "should fail if not logged in" do
      do_get_with_user(nil)
      response.headers["Status"].should == "404 Not Found"
    end
    
    it "should fail if user is not admin" do
      do_get_with_user(mock_model(User, :admin => false))
      response.headers["Status"].should == "404 Not Found"
    end
    
    it "should succeed if user is admin" do
      do_get_with_user(mock_model(User, :admin => true))
      response.headers["Status"].should == "200 OK"
    end
  end
end