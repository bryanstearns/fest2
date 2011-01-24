require File.dirname(__FILE__) + '/../spec_helper'

describe "Basic Subscription" do

  before(:each) do
    @subscription = Subscription.new
  end

  it "should be valid" do
    @subscription.should_not be_valid
    @subscription.user_id = 999
    @subscription.festival_id = 1022
    @subscription.should be_valid
  end

  it "should handle time restrictions" do
    now = Time.zone.local(2000, 1, 1)
    @subscription.festival = mock_model(Festival, :starts => now)
    @subscription.time_restriction_text = "1/3 10am-2pm, 1/5 6pm-"
    @subscription.time_restrictions.should == [
      TimeRestriction.new(Time.zone.local(2000, 1, 3, 10, 0),
                      Time.zone.local(2000, 1, 3, 14, 0)), 
      TimeRestriction.new(Time.zone.local(2000, 1, 5, 18, 0),
                      Time.zone.local(2000, 1, 5, 23, 59, 59)), 
    ]
    @subscription.time_restriction_text.should == "1/3 10am-2pm, 1/5 6pm-"
  end

  describe "key handling" do
    before(:each) do
      @subscription = Subscription.new(:festival_id => 999, :user_id => 999)
    end

    it "should assign a key on save" do
      @subscription.key.should be_nil
      @subscription.save!
      @subscription.key.should_not be_nil
    end

    it "should not replace an existing key" do
      @subscription.key = "12345"
      @subscription.save!
      @subscription.key.should == "12345"
    end
  end
end

=begin
context "Subscription with fixtures" do
  fixtures :users, :festivals, :subscriptions

  # removed obsolete tests; might need this again... 
end
=end
