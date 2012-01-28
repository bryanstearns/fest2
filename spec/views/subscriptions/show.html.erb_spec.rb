require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/subscriptions/show.html.erb" do
  include SubscriptionsHelper
  
  before do
    @festival = mock_model(Festival, :name => "howdy", :dates => "dates",
      :location => "bogusville", :locations => [], :has_press_screenings? => false,
      :has_travel_times? => true, :travel_time_filename => "foo.xls")
    @subscription = mock_model(Subscription, :show_press => false, :use_travel_time => false,
      :restriction_text => "")
    assigns[:festival] = @festival
    assigns[:subscription] = @subscription
  end

  it "should render edit form" do
    render "/subscriptions/show.html.erb"
    
    response.should have_tag("form[action=#{festival_assistant_path(@festival)}][method=post]") do
    end
  end
end

