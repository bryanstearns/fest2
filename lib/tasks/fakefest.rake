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
  
  days = rand(3) + 2
  starts = Date.today + 1
  sequelFest = Festival.create!(:name => "SequelFest",
                                :slug => "sql_#{Date.today.year}",
                                :slug_group => "sql",
                                :location => "Portland, OR",
                                :starts => starts,
                                :ends => starts + days,
                                :updates_url => "http://sequelfest.s15k.com/updates",
                                :public => true, :scheduled => true)
  puts sequelFest.inspect

  # One room per day, plus one, in two venue groups
  counts = {"Cinema" => 0, "Multiplex" => 0}
  venues = (0 .. days+1).collect do |i|
    group = counts.keys[i > ((days+1)/2) ? 0 : 1]
    index = counts[group] += 1
  	sequelFest.venues.create!(:name => "#{group} #{index}", :abbrev => "#{group[0..0]}#{index}",
                              :group => group)
  end
  puts "#{venues.size} venues created"

  # Fill the schedule. Each day is roughly 11 hours long; with an average film
  # duration of 90 minutes, that's 7 slots per venue per day. Figure we want
  # three showings of each film.
  film_count = ((sequelFest.duration * venues.size) * 7) / 3
  puts "Programming #{film_count} films for #{sequelFest.duration} days in #{venues.size} venues"
  films = []
  (sequelFest.starts..(sequelFest.ends + 1)).each do |day|
    puts "Scheduling day #{(day - sequelFest.starts) + 1}: #{day}"
    venues.each do |v|
      t = Time.zone.local(day.year, day.month, day.day, 11, 00, 00, 00) + (rand(5) * 10).minutes
      dayEnd = Time.zone.local(day.year, day.month, day.day, 22, 00, 00, 00)
      puts "T=#{t}"
      while t < dayEnd
        if films.size < film_count
          f = sequelFest.films.create!(:name => film_name,
                                       :duration => (60 + (rand(5) * 9)).minutes)
          films << f
        else
          f = films.sample
        end
        
        s = v.screenings.create!(:film => f, :starts => t)
        t += f.duration + (10 + rand(15)).minutes
        puts "Showing '#{f.name}' at #{v.name}, #{s.starts} - #{s.ends}"
      end
    end
  end
    
  # Do a tiny festival: one day, one venue, one film, three screenings.
  day = Date.today + 7
  tinyFest = Festival.create!(:name => "LebowskiFest", :starts => day, :ends => day,
                              :slug => "lebowski_#{Date.today.year}",
                              :slug_group => "lebowski",
                              :location => "Encino, CA",
                              :film_url_format => "http://imdb.com/title/*/",
                              :updates_url => "http://lebowskifest.s15k.com/updates",
                              :public => true, :scheduled => true)
  solo = tinyFest.venues.create!(:name => "Solo Theatre", :abbrev => "Solo")
  tbl = tinyFest.films.create!(:name => "The Big Lebowski",
                               :url_fragment => "tt0118715",
                               :description => "One man, One ball, ten pins, many droppings of the f-bomb, numerous white russians, a toe, and a rug that really made the room.",
                               :duration => 117.minutes)
  t = Time.local(day.year, day.month, day.day, 10, 00, 00, 00)
  3.times do 
    s = solo.screenings.create(:film => tbl, :starts => t)
    t += s.duration + 10.minutes
  end

  # Do a private festival in the future, as well as an unscheduled public one
  sekritFest = Festival.create!(:name => "SekritFest", :starts => day + 90, :ends => day + 95,
                                :slug => "sekrit", :slug_group => "sekrit",
                                :location => "(undisclosed location)",
                                :public => false, :scheduled => false)
  futureFest = Festival.create!(:name => "FutureFest", :starts => day + 180, :ends => day + 182,
                                :slug => "future", :slug_group => "future",
                                :location => "Utopia",
                                :public => true, :scheduled => false)

  # Create our users, and subscribe to a couple of festivals
  user = User.new(:username => "Bryan Stearns",
                  :password => "xXxXxXxXxXx",
                  :password_confirmation => "xXxXxXxXxXx",
                  :email => "stearns@example.com")
  user.admin = true # attr_accessible makes us do this separately
  user.save!
  users = { :stearns => user }
  [['ebert', 'siskel'], ['siskel', 'ebert']].each do |username, password|
    user = User.create!(:username => username,
                        :password => password,
                        :password_confirmation => password,
                        :mail_opt_out => (username == 'siskel'),
                        :email => "stearns@example.com")
    #puts "User #{user.username} created (#{user.id})"
    users[username.to_sym] = user
  end  
  users[:stearns].subscriptions.create!(:festival => sequelFest, :admin => true)
  users[:ebert].subscriptions.create!(:festival => sequelFest, :admin => true)
  users[:ebert].subscriptions.create!(:festival => tinyFest)
  users[:siskel].subscriptions.create!(:festival => tinyFest, :admin => true)

  # Prioritize most films
  priorities = [0,1,2,4,8]
  sequelFest.films.all(:order => :name).each do |film|
    if rand < 0.9
      priority = priorities[rand(5)]
      puts "Prioritizing #{film.id}: #{film.name} at #{priority}"
      users[:stearns].picks.create!(:film => film, :priority => priority)
    else
      puts "Not prioritizing #{film.id}: #{film.name}"
    end
  end

  # Add three recent announcements
  now = Time.zone.now
  Announcement.create!(:subject => "Oldest",
                       :contents => "The oldest announcement.",
                       :published_at => now - 5.days,
                       :published => true)
  Announcement.create!(:subject => "Older",
                       :contents => "An older announcement.",
                       :published_at => now - 4.days,
                       :published => true)
  Announcement.create!(:subject => "Old",
                       :contents => "An old announcement.",
                       :published_at => now - 3.days,
                       :published => true)
  Announcement.create!(:subject => "Draft",
                       :contents => "An unpublished announcement.",
                       :published_at => now - 2.days)
  Announcement.create!(:subject => "New",
                       :contents => "A new announcement.",
                       :published_at => now - 2.days,
                       :published => true)
end  
