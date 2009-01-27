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
end

=begin
context "Subscription with fixtures" do
  fixtures :users, :festivals, :subscriptions

  # removed obsolete tests; might need this again... 
end
=end