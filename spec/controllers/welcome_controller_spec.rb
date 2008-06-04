require File.dirname(__FILE__) + '/../spec_helper'

context WelcomeController do
  fixtures :festivals, :announcements
  
  setup do
    get 'index'
  end
  
  it "should use WelcomeController" do
    controller.should be_an_instance_of(WelcomeController)
  end

  it "should be successful" do
    response.should be_success
  end
  
  it "should include the right festivals" do
    # festivals(:secret) isn't public.
    assigns[:upcoming_festivals].should == [festivals(:interyear)]
    assigns[:past_festivals].to_set.should == [festivals(:intermonth), festivals(:intramonth)].to_set
  end
end
