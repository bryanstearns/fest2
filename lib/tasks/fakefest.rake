desc 'Generate fake festival'

$relatives = ['Bride of', 'Son of', 'Cousin to', 'Aunt of', 'Niece of', 
             'Plumber of', 'Stepsister of', 'Great-Grandmother of', 
             'Kindergarten Teacher of', 'Beyond the Valley of',
             'Beneath', 'Next to', 'Upstairs from', 'Deep Inside', 
             'After', 'Before', 'Sequel to' ]
$numbers = (1..12).to_a.map {|i| i * 17}

$protofilms = [
  [ '#{x} Chucky', $relatives ],
  [ '#{x} Frankenstein', $relatives ],
  [ '#{x} the Planet of the Apes', $relatives ],
  [ '#{x} the Thin Man', $relatives ],
  [ 'Halloween #{x}', $numbers ],
  [ 'Rocky #{x}', $numbers ],
  [ 'Home Alone #{x}', $numbers ],
]

$used_film_names = Set.new
def film_name
  while true
    fmt, choices = $protofilms[rand($protofilms.size)]
    choice = rand(choices.size)
    x = choices[choice]
    name = fmt.sub('#{x}', x.to_s)
    if not $used_film_names.include?(name)
      $used_film_names << name
      return name
    end
  end
end

task :fakefest => :environment do
  ActiveRecord::Base.establish_connection
  
  days = rand(3) + 1
  sequelFest = Festival.create(:name => "SequelFest",
                               :location => "Portland, OR",
                               :starts => Date.today - 2,
                               :ends => (Date.today - 2)  + days,
                               :public => true, :scheduled => true)
  puts sequelFest.inspect

  # One room per day, plus one
  venues = (0 .. days+1).collect do |i|
  	sequelFest.venues.create(:name => "Cinema #{i+1}", :abbrev => "C#{i+1}")
  end
  puts "#{venues.size} venues created"

  # Fill the schedule. Figure roughly 6 slots a day per venue, and three
  # showings per film
  film_count = ((sequelFest.duration * venues.size) * 6) / 3
  films = []
  (sequelFest.starts..(sequelFest.ends + 1)).each do |day|
    puts "Scheduling day #{(day - sequelFest.starts) + 1}: #{day}"
    venues.each do |v|
      t = Time.mktime(day.year, day.month, day.day, 11, 00, 00, 00) + (rand(5) * 10).minutes
      dayEnd = Time.mktime(day.year, day.month, day.day, 22, 00, 00, 00)
      #puts "T=#{t}"
      while t < dayEnd
        if films.size < film_count
          f = sequelFest.films.create(:name => film_name, 
                                      :duration => (60 + (rand(5) * 9)).minutes)
          films << f
        else
          f = films.rand
        end
        
        s = v.screenings.create(:film => f, :starts => t)
        t += f.duration + (10 + rand(15)).minutes
        puts "Showing '#{f.name}' at #{v.name}, #{s.starts} - #{s.ends}"
      end
    end
  end
    
  # Do a tiny festival: one day, one venue, one film, three screenings.
  day = Date.today + 7
  tinyFest = Festival.create(:name => "LebowskiFest", :starts => day, :ends => day,
                             :location => "Encino, CA",
                             :film_url_format => "http://imdb.com/title/*/",
                             :public => true, :scheduled => true)
  solo = tinyFest.venues.create(:name => "Solo Theatre", :abbrev => "Solo")
  tbl = tinyFest.films.create(:name => "The Big Lebowski",
                              :url_fragment => "tt0118715",
                              :description => "One man, One ball, ten pins, many droppings of the f-bomb, numerous white russians, a toe, and a rug that really made the room.",
                              :duration => 117.minutes)
  t = Time.mktime(day.year, day.month, day.day, 10, 00, 00, 00)
  3.times do 
    s = solo.screenings.create(:film => tbl, :starts => t)
    t += s.duration + 10.minutes
  end

  # Do a private festival in the future, as well as an unscheduled public one
  sekritFest = Festival.create(:name => "SekritFest", :starts => day + 90, :ends => day + 95,
                               :location => "(undisclosed location)",
                               :public => false, :scheduled => false)
  futureFest = Festival.create(:name => "FutureFest", :starts => day + 180, :ends => day + 182,
                               :location => "Utopia",
                               :public => true, :scheduled => false)

  # Create our users, and subscribe to a couple of festivals
  user = User.new(:username => "stearns",
                  :password => "xXxXxXxXxXx",
                  :password_confirmation => "xXxXxXxXxXx",
                  :email => "stearns@example.com")
  user.admin = true # attr_accessible makes us do this separately
  user.save!
  users = { :stearns => user }
  [['ebert', 'siskel'], ['siskel', 'ebert']].each do |username, password|
    user = User.create(:username => username,
                       :password => password,
                       :password_confirmation => password,
                       :email => "stearns@example.com")
    #puts "User #{user.username} created (#{user.id})"
    users[username.to_sym] = user
  end  
  users[:ebert].subscriptions.create(:festival => sequelFest, :admin => true)
  users[:ebert].subscriptions.create(:festival => tinyFest)
  users[:siskel].subscriptions.create(:festival => tinyFest, :admin => true)

  # Add three recent announcements
  now = Time.now
  Announcement.create(:subject => "Oldest", 
                      :contents => "The oldest announcement.",
                      :published_at => now - 5.days,
                      :published => true)
  Announcement.create(:subject => "Older", 
                      :contents => "An older announcement.",
                      :published_at => now - 4.days,
                      :published => true)
  Announcement.create(:subject => "Old",
                      :contents => "An old announcement.",
                      :published_at => now - 3.days,
                      :published => true)
  Announcement.create(:subject => "Draft", 
                      :contents => "An unpublished announcement.",
                      :published_at => now - 2.days)
  Announcement.create(:subject => "New", 
                      :contents => "A new announcement.",
                      :published_at => now - 2.days,
                      :published => true)
end  
