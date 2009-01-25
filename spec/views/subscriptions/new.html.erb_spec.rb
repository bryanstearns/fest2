require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/new.html.erb" do
  include SubscriptionsHelper
  
  before(:each) do
    @subscription = mock_model(Subscription)
    @subscription.stub!(:new_record?).and_return(true)
    assigns[:subscription] = @subscription
  end

  it "should render new form" do
    render "/subscriptions/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", subscriptions_path) do
    end
  end
end


