require File.dirname(__FILE__) + '/../spec_helper'

describe Venue do
  fixtures :festivals
  
  before(:each) do
    @venue = Venue.new
  end

  it "should be valid" do
     @venue.should_not be_valid
     @venue.name = "Movieplex"
     @venue.abbrev = "MP"
     @venue.festival = festivals(:intramonth)
     @venue.should be_valid
  end
end
