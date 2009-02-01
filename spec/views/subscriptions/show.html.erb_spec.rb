require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/show.html.erb" do
  include SubscriptionsHelper
  include ConferenceVsFestivalHelper
  
  before do
    @festival = mock_model(Festival, :name => "howdy", :dates => "dates",
      :has_press_screenings? => false)
    @subscription = mock_model(Subscription, :show_press => false,
      :restriction_text => "")
    assigns[:festival] = @festival
    assigns[:subscription] = @subscription
  end

  it "should render edit form" do
    render "/subscriptions/show.html.erb"
    
    response.should have_tag("form[action=#{festival_settings_path(@festival)}][method=post]") do
    end
  end
end

