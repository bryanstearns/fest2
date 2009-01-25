require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/show.html.erb" do
  include SubscriptionsHelper
  
  before(:each) do
    @subscription = mock_model(Subscription)

    assigns[:subscription] = @subscription
  end

  it "should render attributes in <p>" do
    render "/subscriptions/show.html.erb"
  end
end

