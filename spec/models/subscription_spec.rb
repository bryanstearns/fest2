require File.dirname(__FILE__) + '/../spec_helper'

context "Subscription with fixtures loaded" do
  fixtures :users, :festivals

  before(:each) do
    @subscription = Subscription.new
  end

  it "should be valid" do
    @subscription.should_not be_valid
    @subscription.user = users(:quentin)
    @subscription.festival = festivals(:intramonth)
    @subscription.should be_valid
  end
end
