require File.dirname(__FILE__) + '/../spec_helper'

context "Pick with fixtures loaded" do
  fixtures :users, :festivals, :films, :screenings, :picks
  
  before(:each) do
    @pick = Pick.new
  end

  it "should be valid" do
    @pick.should_not be_valid
    @pick.film = films(:third_man)
    @pick.user = users(:aaron)
    @pick.festival = festivals(:intramonth)
    @pick.should be_valid
  end

  #it "should find conflicts" do
  #  picks(:quentin_one).conflicts.should == []
  #end
end
