require File.dirname(__FILE__) + '/../../spec_helper'

describe "/films/show.html.erb" do
  include FilmsHelper
  
  before(:each) do
    @festival = mock_model(Festival)
    @film = mock_model(Film)

    assigns[:festival] = @festival
    assigns[:film] = @film
  end

  it "should render attributes in <p>" do
    render "/films/show.html.erb"
  end
end

