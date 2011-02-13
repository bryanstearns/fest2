require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe "A new Screening" do
  it "should require start and end times" do
    lambda { Screening.new(:starts => nil).should have(1).errors_on(:starts) }.
           should_not change(Screening, :count)
    lambda { Screening.new(:ends => nil).should have(1).errors_on(:ends) }.
           should_not change(Screening, :count)
  end

  it "should require sequential start and end times" do
    lambda { Screening.new(:starts => Time.zone.parse("1998-05-01 15:00"),
                           :ends => Time.zone.parse("1998-05-01 12:30")).\
             should have(1).errors_on(:ends) }.
           should_not change(Screening, :count)
  end
end

describe "Screening with fixtures loaded" do 
  fixtures :users, :films, :venues, :screenings, :picks, :festivals
  
  it "should return properly formatted times" do
    screenings(:early_one).times.should == "9:45 - 11:45 am" # same half of the day
    screenings(:early_two).times.should == "10:00 am - noon" # test "noon" case
    screenings(:early_three).times.should == "11:40 am - 12:10 pm" # test spans noon
    screenings(:late_three).times.should == "11:00 pm - 1:00 am" # test spans midnight
  end
  
  it "should detect individual conflicts properly" do
    screenings(:early_one).conflicts_with(screenings(:late_two)).should == false
    screenings(:early_two).conflicts_with(screenings(:early_three)).should == true
  end
  
  it "should gather conflicts properly" do
    screenings(:early_two).conflicting_picks(users(:quentin)).should \
      == [picks(:quentin_one)]
  end
  
  it "should unselect conflicting screenings" do
    # :quentin starts with early_one and late_two selected; selecting late_one should
    # unselect both.
    picks(:quentin_one).screening.should == screenings(:early_one)
    screenings(:early_two).set_state(users(:quentin), :picked).to_set.should \
      == [screenings(:late_two), screenings(:early_two), screenings(:late_one),
          screenings(:early_one)].to_set
  end

  it "should unselect non-conflicting screenings" do
    picks(:quentin_one).screening.should == screenings(:early_one)
    screenings(:early_one).set_state(users(:quentin), :unpicked).to_set.should \
      == [screenings(:late_one), screenings(:early_one)].to_set
  end
end
