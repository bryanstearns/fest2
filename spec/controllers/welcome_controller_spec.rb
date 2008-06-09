require File.dirname(__FILE__) + '/../spec_helper'

context WelcomeController do
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
  
  it "should include the right festivals" do
    do_get
    # festivals(:secret) isn't public.
    assigns[:upcoming_festivals].should == [festivals(:interyear)]
    assigns[:past_festivals].to_set.should == [festivals(:intermonth), festivals(:intramonth)].to_set
  end
end
