require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/index.html.erb" do
  include FestivalsHelper
  include ConferenceVsFestivalHelper
  
  before do
    force_festival_mode    
    festival_98 = mock_model(Festival, :scheduled => true,
      :public => true, :name => "Festival98", :slug => "MyString",
      :location => "San Jose", :dates => "dates")
    festival_99 = mock_model(Festival, :scheduled => true,
      :public => true, :name => "Festival99", :slug => "MyString",
      :location => "San Jose", :dates => "dates")
    assigns[:festivals] = [festival_98, festival_99]
  end

  it "should render list of festivals" do
    render "/festivals/index.html.erb"
    response.should have_tag("li>a", "Festival98", 2)
    response.should have_tag("li>a", "Festival99", 2)
  end
end

