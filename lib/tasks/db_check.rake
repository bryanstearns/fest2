require 'yaml'
require 'erb'
require 'ruby-debug'

namespace :db do
  desc "Check integrity of the database"

  task :check => :environment do
    puts "# Loading..."
    festivals = make_map(Festival)
    films = make_map(Film)
    picks = make_map(Pick)
    screenings = make_map(Screening)
    venues = make_map(Venue)
    users = make_map(User)
    puts "# Done loading: #{festivals.size} festivals, #{venues.size} venues, #{films.size} films, #{picks.size} picks, #{screenings.size} screenings, #{users.size} users." 

    puts "# Checking venues"
    any_bad = false
    venues.values.each do |v|
      # Does every venue have a festival?
      bad_fest = check(festivals[v.festival_id], "missing festival", v)
      bad = bad_fest
      delete_it(v) if bad
      any_bad = any_bad or bad
    end
    puts "# Venues are #{any_bad ? "bad" : "good"}"

    puts "# Checking films"
    any_bad = false
    films.values.each do |f|
      # Does every film have a festival?
      bad_film = check(festivals[f.festival_id], "missing festival", f)
      bad = bad_film
      delete_it(f) if bad
      any_bad = any_bad or bad
    end
    puts "# Films are #{any_bad ? "bad" : "good"}"

    puts "# Checking screenings"
    any_bad = false
    screenings.values.each do |s|
      # Does every screening have a film, festival, & venue?
      bad_film = check(films[s.film_id], "missing film", s)
      bad_fest = check(festivals[s.festival_id], "missing festival", s)
      bad_ven = check(venues[s.venue_id], "missing venue", s)
      bad = bad_film or bad_fest or bad_ven
      delete_it(s) if bad
      any_bad = any_bad or bad
    end
    puts "# Screenings are #{any_bad ? "bad" : "good"}"

    puts "# Checking picks"
    any_bad = false
    picks.values.each do |p|
      # Does every pick have a film, festival, & user, and 
      # maybe a screening?
      bad_film = check(films[p.film_id], "missing film", p)
      bad_fest = check(festivals[p.festival_id], "missing festival", p)
      bad_user = check(users[p.user_id], "missing user", p)
      bad_scr = check((p.screening_id.nil? or screenings[p.screening_id]), "missing screening", p)
      bad = bad_film or bad_fest or bad_user or bad_scr
      delete_it(p) if bad
      any_bad = any_bad or bad
    end
    puts "# Picks are #{any_bad ? "bad" : "good"}"
  end
    
  def check(x, message=nil, object=nil)
    return false if x
    message ||= "check failed"
    #object = object ? " for #{object.inspect rescue "#{object.class}##{object.id}"}" : ""
    object = object ? " for #{object.inspect}" : ""
    puts "#   #{message}#{object}"
    return true
  end

  def delete_it(x)
    puts "DELETE FROM #{x.class.table_name} WHERE id = #{x.id};"
  end

  def make_map(klass)
    klass.all.inject({}) { |h, record| h[record.id] = record; h }
  end
end
