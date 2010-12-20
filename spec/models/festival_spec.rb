require File.dirname(__FILE__) + '/../spec_helper'

describe "A new Festival" do
  it "should require name" do
    Festival.new(:name => nil).should have(1).errors_on(:name)
  end

  it "should require slug" do
    Festival.new(:slug => nil).should have(1).errors_on(:slug)
  end

  it "should require start and end dates" do
    Festival.new(:starts => nil).should have(1).errors_on(:starts)
    Festival.new(:ends => nil).should have(1).errors_on(:ends)
  end

  it "should require sequential start and end dates" do
    Festival.new(:starts => Date.civil(1998, 5, 1), 
                 :ends => Date.civil(1998, 4, 23)).
             should have(1).errors_on(:ends)
  end

  it "should validate the film URL format" do
    # Empty is ok.
    Festival.new().
             should have(0).errors_on(:film_url_format)
    # A good URL with a single * is good.
    Festival.new(:film_url_format => "https://foo.com/*.html").
             should have(0).errors_on(:film_url_format)
    # Not a URL, extra *, * in wrong place: bad.
    Festival.new(:film_url_format => "bad").
             should have(1).errors_on(:film_url_format)
    Festival.new(:film_url_format => "https://foo.com/*.*.html").
             should have(1).errors_on(:film_url_format)
    Festival.new(:film_url_format => "https://*.com/foo.html").
             should have(1).errors_on(:film_url_format)
  end
end

describe "Festival with fixtures loaded" do 
  fixtures :festivals, :films, :venues

# (no longer automatic)
#  it "should automatically update its slug" do
#    festivals(:intramonth).name = "Bogus!Name"
#    festivals(:intramonth).save!
#    festivals(:intramonth).slug.should == "Bogus-Name"
#    festivals(:intramonth).to_param.should == festivals(:intramonth).slug
#  end

  it "should return properly formatted dates" do
    festivals(:intramonth).dates.should == "May 1 - 3, 1997"
    festivals(:intermonth).dates.should == "May 28 - June 5, 1998"
    festivals(:interyear).dates.should == "December 28, 2019 - January 4, 2020"
  end
  
  it "should convert itself to icalendar format" do
    festivals(:intramonth).to_ics(1).should match(/BEGIN:VCALENDAR.*/)
  end
  
  it "should provide good URLs for its films" do
    festivals(:intramonth).external_film_url(films(:one_flew)).should == \
      "http://example.com/films/1.html"
    festivals(:intermonth).external_film_url(films(:two_moon)).should == \
      "http://example.com/films/TwoMoon"
    festivals(:intermonth).external_film_url(films(:third_man)).should be_nil
  end
end
