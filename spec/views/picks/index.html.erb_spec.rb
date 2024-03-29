require File.dirname(__FILE__) + '/../../spec_helper'

describe "/picks/index.html.erb" do
  include FilmsHelper

  before(:each) do
    now = Time.zone.now
    festival = mock_model(Festival, :name => "name", :dates => "dates",
                          :location => "bogusville",
                          :external_film_url => "http://foo/0",
                          :slug_group => "sluggo")
    assigns[:festival] = festival

    venue = mock_model(Venue, :name => "Venue Name")
    user = mock_model(User)
    screenings = [
      mock_model(Screening, :venue => venue,
                 :starts => now - 3.hours,
                 :ends => now - 2.hours,
                 :date_and_times => "past",
                 :press => false),
      mock_model(Screening, :venue => venue,
                 :starts => now + 1.hour,
                 :ends => now + 2.hours,
                 :date_and_times => "future",
                 :press => false),
      mock_model(Screening, :venue => venue,
                 :starts => now - 1.hour,
                 :ends => now + 10.minutes,
                 :date_and_times => "current",
                 :press => false),
    ]

    films = [
      mock_model(Film, :name => "Last Film", :id => 1, :minutes => 58, :festival => festival,
                 :screenings => screenings, :public_screenings => screenings,
                 :description => nil, :sort_name => "Last Film",
                 :countries => nil, :country_names => ""),
      mock_model(Film, :name => "The First Film", :id => 2, :minutes => 90, :festival => festival,
                 :screenings => [], :public_screenings => [],
                 :description => "This would be a description of the film.",
                 :sort_name => "First Film", :countries => "dk", :country_names => "Denmark"),
    ]
    assigns[:films] = films

    assigns[:picks] = {
      films[0].id => mock_model(Pick, :film => films[0], :priority => 1, :rating => nil, :screening => nil),
      films[1].id => mock_model(Pick, :film => films[1], :priority => 2, :rating => nil, :screening => nil),
    }
  end

  it "should render list of films with screenings" do
    render "/picks/index.html.erb"
    response.should have_text(/Last Film/)
    response.should have_text(/past: Venue Name/)
    response.should have_text(/future: Venue Name/)
    response.should have_text(/current: Venue Name/)
  end

  it "should render screenings in order" do
    render "/picks/index.html.erb"
    past_index = response.body.index("past: Venue Name")
    current_index = response.body.index("current: Venue Name")
    future_index = response.body.index("future: Venue Name")
    past_index.should satisfy {|i| i < current_index }
    current_index.should satisfy {|i| i < future_index }
  end

  it "should render picks" do
    render "/picks/index.html.erb"
    response.should have_tag("input#film_1_priority")
  end

  it "should render ratings" do
    render "/picks/index.html.erb"
    response.should have_tag("input#film_1_rating")
  end
end
