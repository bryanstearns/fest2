require File.dirname(__FILE__) + '/../spec_helper'

context "A new film" do
  fixtures :festivals

  it "should require name" do
    lambda{ Film.create(:name => nil).should have_at_least(1).errors_on(:name)}.
          should_not change(Film,:count) 
  end

  it "should require duration" do
    lambda{ Film.create(:duration => nil).should have_at_least(1).errors_on(:duration)}.
          should_not change(Film,:count)
  end

  it "should be created if complete" do
    lambda{ Film.create({ :name => "Bambi Meets Godzilla", :duration => 97,
                          :festival => festivals(:intramonth) } ) }.
          should change(Film, :count)
  end
  
  it "should convert between minutes and duration" do
    f = Film.create({ :name => "x", :duration => 7200,
                  :festival => festivals(:intramonth)})
    f.minutes.should == 120
    f.minutes = 90
    f.duration.should == 5400
    g = Film.create({ :name => "y", :minutes => 120,
                  :festival => festivals(:intramonth)})
    g.duration.should == 7200
  end
  
  it "should convert between country names and symbols" do
    f = Film.create()
    f.countries.should == nil
    f.country_names.should == ''
    
    f.country_names = "Denmark"
    f.countries.should == "dk"
    
    f.countries = "fi se"
    f.country_names.should == "Finland, Sweden"
  end
end