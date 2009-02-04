require File.dirname(__FILE__) + '/../../spec_helper'

describe "/films/index.html.erb" do
  include FilmsHelper
  
  before(:each) do
    now = Time.now
    festival = mock_model(Festival, :name => "name", :dates => "dates", 
                          :external_film_url => "http://foo/0")
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
                 :countries => nil, :country_names => "",
                 :amazon_asin => "blah", :amazon_confirmed => false, :amazon_url => "x"),
      mock_model(Film, :name => "The First Film", :id => 2, :minutes => 90, :festival => festival, 
                 :screenings => [], :public_screenings => [],
                 :description => "This would be a description of the film.",
                 :sort_name => "First Film", :countries => "dk", :country_names => "Denmark",
                 :amazon_asin => "blah", :amazon_confirmed => false, :amazon_url => "x"),
    ]
    assigns[:films] = films
    
    assigns[:picks] = { 
      films[0].id => mock_model(Pick, :film => films[0], :priority => 1, :screening => nil),
      films[1].id => mock_model(Pick, :film => films[1], :priority => 2, :screening => nil),
    }
  end

  it "should render list of films with screenings" do    
    render "/films/index.html.erb"
    response.should have_text(/Last Film/)
    response.should have_text(/past: Venue Name/)
    response.should have_text(/future: Venue Name/)
    response.should have_text(/current: Venue Name/)
  end

  it "should render screenings in order" do
    render "/films/index.html.erb"
    # Completed screenings should be at the end of the list
    past_index = response.body.index("past: Venue Name")
    current_index = response.body.index("current: Venue Name")
    future_index = response.body.index("future: Venue Name")
    current_index.should satisfy {|i| i < future_index }
    future_index.should satisfy {|i| i < past_index }
  end
  
  it "shouldn't render picks unless logged in" do
    render "/films/index.html.erb"
    response.should_not have_tag("img.priority")
  end
  
  it "should render picks if logged in" do
    template.should_receive(:logged_in?).any_number_of_times.and_return(true)
    render "/films/index.html.erb"
    response.should have_tag("input#film_1_pick_0")
  end
  
  it "should include the DVD icon for films with an ASIN" do
    render "/films/index.html.erb"
    response.should have_tag("#film_1 img")
  end
end

