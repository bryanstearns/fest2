require File.dirname(__FILE__) + '/../spec_helper'

describe WelcomeController do
  fixtures :festivals, :announcements
  
  def do_get
    get 'index'
  end
  
  it "should use WelcomeController" do
    do_get
    controller.should be_an_instance_of(WelcomeController)
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
end
