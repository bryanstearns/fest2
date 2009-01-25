require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/index.html.erb" do
  include SubscriptionsHelper
  
  before(:each) do
    subscription_98 = mock_model(Subscription)
    subscription_99 = mock_model(Subscription)

    assigns[:subscriptions] = [subscription_98, subscription_99]
  end

  it "should render list of subscriptions" do
    render "/subscriptions/index.html.erb"
  end
end

