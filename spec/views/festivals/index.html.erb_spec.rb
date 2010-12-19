require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/index.html.erb" do
  include FestivalsHelper
  
  before do
    festival_98 = mock_model(Festival, :scheduled => true,
      :public => true, :name => "Festival98", :slug => "MyString",
      :slug_group => "a", :location => "San Jose", :dates => "dates",
      :starts => Date.today, :ends => Date.today)
    festival_99 = mock_model(Festival, :scheduled => true,
      :public => true, :name => "Festival99", :slug => "MyString",
      :slug_group => "b", :location => "San Jose", :dates => "dates",
      :starts => Date.today, :ends => Date.today)
    assigns[:festivals_grouped] = [[festival_98], [festival_99]]
  end

  it "should render list of festivals" do
    render "/festivals/index.html.erb"
    response.should have_tag("li>span", "Festival98", 2)
    response.should have_tag("li>span", "Festival99", 2)
  end
end

