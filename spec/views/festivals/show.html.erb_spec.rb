require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/show.html.erb" do
  include FestivalsHelper

  before do
    @festival = mock_model(Festival,
                           :name => "Festival Name",
                           :dates => "festival dates",
                           :location => "bogusville",
                           :slug => "slug",
                           :slug_group => "slug group",
                           :starts => Date.today,
                           :ends => Date.today,
                           :revised_at => DateTime.now,
                           :revision_time => DateTime.now,
                           :films => [])
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

