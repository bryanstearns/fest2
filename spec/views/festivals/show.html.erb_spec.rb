require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/show.html.erb" do
  include FestivalsHelper
  include ConferenceVsFestivalHelper

  before do
    force_festival_mode
    @festival = mock_model(Festival)
    @festival.stub!(:name).and_return("Festival Name")
    @festival.stub!(:dates).and_return("festival dates")
    @festival.stub!(:slug).and_return("MyString")
    @festival.stub!(:starts).and_return(Date.today)
    @festival.stub!(:ends).and_return(Date.today)
    @festival.stub!(:films).and_return([])
    screenings = []
    screenings.stub!(:with_press).and_return([])
    @festival.stub!(:screenings).and_return(screenings)
    
    assigns[:festival] = @festival
    
    @picks = []
    assigns[:picks] = @picks
  end

  it "should render certain festival attributes" do
    render "/festivals/show.html.erb"
    # FIXME: These are in the :header section, which isn't rendered by the test...
    #response.should have_text(/Festival Name/)
    #response.should have_text(/festival dates/)
  end
end

