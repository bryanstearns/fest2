require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/index.html.erb" do
  include FestivalsHelper
  include ConferenceVsFestivalHelper
  
  before do
    force_festival_mode    
    festival_98 = mock_model(Festival)
    festival_98.should_receive(:name).and_return("MyString")
    festival_98.should_receive(:slug).and_return("MyString")
    festival_98.should_receive(:location).and_return("MyString")
    festival_98.should_receive(:dates).and_return("MyString")
    festival_99 = mock_model(Festival)
    festival_99.should_receive(:name).and_return("MyString")
    festival_99.should_receive(:slug).and_return("MyString")
    festival_99.should_receive(:location).and_return("MyString")
    festival_99.should_receive(:dates).and_return("MyString")

    assigns[:festivals] = [festival_98, festival_99]
  end

  it "should render list of festivals" do
    render "/festivals/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end

