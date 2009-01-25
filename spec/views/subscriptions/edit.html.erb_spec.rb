require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/edit.html.erb" do
  include SubscriptionsHelper
  
  before do
    @subscription = mock_model(Subscription)
    assigns[:subscription] = @subscription
  end

  it "should render edit form" do
    render "/subscriptions/edit.html.erb"
    
    response.should have_tag("form[action=#{subscription_path(@subscription)}][method=post]") do
    end
  end
end


