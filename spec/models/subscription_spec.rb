require File.dirname(__FILE__) + '/../spec_helper'

context "Basic Subscription" do

  before(:each) do
    @subscription = Subscription.new
  end

  it "should be valid" do
    @subscription.should_not be_valid
    @subscription.user_id = 999
    @subscription.festival_id = 1022
    @subscription.should be_valid
  end

  it "should handle restrictions" do
    now = Time.zone.local(2000, 1, 1)
    @subscription.festival = mock_model(Festival, :starts => now)
    @subscription.restriction_text = "1/3 10am-2pm, 1/5 6pm-"
    @subscription.restrictions.should == [
      Restriction.new(Time.zone.local(2000, 1, 3, 10, 0),
                      Time.zone.local(2000, 1, 3, 14, 0)), 
      Restriction.new(Time.zone.local(2000, 1, 5, 18, 0),
                      Time.zone.local(2000, 1, 5, 23, 59, 59)), 
    ]
    @subscription.restriction_text.should == "1/3 10am-2pm, 1/5 6pm-"
  end
end

=begin
context "Subscription with fixtures" do
  fixtures :users, :festivals, :subscriptions

  # removed obsolete tests; might need this again... 
end
=end
