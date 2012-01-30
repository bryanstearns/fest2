class PIFFCSV
  def initialize(festival)
    @festival = festival
    @films = {}
    @venues = {}
    @keys = nil
  end

  def load
    CSV::Reader.parse(File.open('PIFF34FINAL.csv', 'rb')) do |row|
      if @keys.nil?
        @keys = parse_keys(row)
      elsif row != [nil]
        @values = parse_values(row)
        process_row
      end
    end

    # Add the press screenings, too
    whitsell = @festival.venues.find_by_abbrev!("WH")
    [
        ["2011-01-31 11:00", "Silent Souls"],
        ["2011-01-31 14:00", "Kawasaki's Rose"],
        ["2011-02-01 11:00", "The First Beautiful Thing"],
        ["2011-02-01 14:00", "Incendies"],
        ["2011-02-02 11:00", "If I Want To Whistle, I Whistle"],
        ["2011-02-02 14:00", "Of Gods And Men"],
        ["2011-02-03 11:00", "Son of Babylon"],
        ["2011-02-03 14:00", "The First Grader"],
        ["2011-02-04 11:00", "His &amp; Hers"],
        ["2011-02-04 14:00", "Certified Copy"],
        ["2011-02-07 11:00", "A Family"],
        ["2011-02-07 14:00", "Human Resources Manager"],
        ["2011-02-08 11:00", "Boy"],
        ["2011-02-08 14:00", "Aftershock"],
        ["2011-02-09 11:00", "Steam of Life"],
        ["2011-02-09 14:00", "Uncle Boonmee Who Can Recall His Past Lives"],
        ["2011-02-10 11:00", "La Pivellina"],
        ["2011-02-10 14:00", "The Whistleblower"],
        ["2011-02-11 11:00", "The Four Times"],
        ["2011-02-11 14:00", "The Housemaid"],
        ["2011-02-14 11:00", "How to Die in Oregon"],
        ["2011-02-14 14:00", "Poetry"],
        ["2011-02-15 11:00", "My Joy"],
        # ["2011-02-15 14:00", "TBA"],
        ["2011-02-16 11:00", "In a Better World"],
        ["2011-02-16 14:00", "Passione: A Musical Adventure"],
        ["2011-02-17 12:00", "Even the Rain"],
        ["2011-02-17 15:00", "The Last Circus"],
        ["2011-02-18 11:00", "Of Love and Other Demons"],
        ["2011-02-18 14:00", "When We Leave"],
    ].each do |starts, name|
      film = @festival.films.find_by_name!(name)
      starts = Time.zone.parse(starts)
      @festival.screenings.create!(:film => film,
        :venue => whitsell, :starts => starts,
        :ends => starts + film.duration, :press => true)
    end

    # Make other fixes
    film("His &amp; Hers") {|f| f.name = "His & Hers" }
    film("Revoluci&oacute;n") {|f| f.name = "Revolución" }
    # 2/13
    screening("Kawasaki's Rose", "2011-02-13 14:45") \
      {|s| s.starts = Time.zone.parse("2011-02-13 15:30"); s.venue = venue("B2") }
    screening("Human Resources Manager", "2011-02-13 15:30") \
      {|s| s.starts = Time.zone.parse("2011-02-13 14:45") }
    screening("Incendies", "2011-02-13 16:15") \
      {|s| s.venue = venue("B1") }
    screening("Silent Souls", "2011-02-14 18:00") \
      {|s| s.starts = Time.zone.parse("2011-02-13 16:45") }
    screening("Aftershock", "2011-02-13 19:30") \
      {|s| s.starts = Time.zone.parse("2011-02-13 19:00") }
    screening("Behind Blue Skies", "2011-02-13 20:00") \
      {|s| s.starts = Time.zone.parse("2011-02-13 20:30") }

    # 2/14
    screening("The First Grader", "2011-02-13 16:45") \
      {|s| s.starts = Time.zone.parse("2011-02-14 18:00") }
    screening("Certified Copy", "2011-02-14 20:15") \
      {|s| s.starts = Time.zone.parse("2011-02-14 20:45") }

    # 2/15
    screening("The Arbor", "2011-02-15 14:15")  \
      {|s| s.starts = Time.zone.parse("2011-02-19 14:15") }
    screening("Young Goethe!", "2011-02-15 20:15") \
      {|s| s.starts = Time.zone.parse("2011-02-19 16:00"); s.venue = venue("CM") }
    @festival.screenings.create!(:film => film("Budrus"),
                                 :venue => venue("B1"),
                                 :starts => Time.zone.parse("2011-02-15 20:15"),
                                 :ends => Time.zone.parse("2011-02-15 20:15") + film("Budrus").duration,
                                 :press => false)

    # 2/17
    screening("The Robber", "2011-02-17 19:00") \
      {|s| s.starts = Time.zone.parse("2011-02-18 19:00") }
    screening("The Robber", "2011-02-17 21:00") \
      {|s| s.starts = Time.zone.parse("2011-02-18 21:30") }

    # 2/19
    screening("7 Days in Slow Motion", "2011-02-19 14:00")\
      {|s| s.starts = Time.zone.parse("2011-02-19 13:45") }

    # 2/20
    screening("Flamenco, Flamenco", "2011-02-23 14:30")\
      {|s| s.starts = Time.zone.parse("2011-02-20 14:30") }

    # 2/21
    screening("My Joy", "2011-02-21 14:30")\
      {|s| s.starts = Time.zone.parse("2011-02-21 14:00") }
    screening("A Somewhat Gentle Man", "2011-02-21 14:45")\
      {|s| s.starts = Time.zone.parse("2011-02-21 14:15") }
    screening("In a Better World", "2011-02-21 19:30")\
      {|s| s.starts = Time.zone.parse("2011-02-21 19:15") }

    # 2/22
    screening("Cameraman: the Life and Work of Jack Cardiff", "2011-02-22 20:00")\
      {|s| s.starts = Time.zone.parse("2011-02-22 20:30") }

    # 2/23
    f = @festival.films.create!(:name => "Short Cuts V: Made in Portland",
                                :duration => 90 * 60)
    @festival.screenings.create!(:film => f,
                                 :venue => venue("WH"),
                                 :starts => Time.zone.parse("2011-02-23 18:00"),
                                 :ends => Time.zone.parse("2011-02-23 18:00") + f.duration,
                                 :press => false)
    # 2/24
    screening("Martha", "2011-02-24 20:15") \
      {|s| s.starts = Time.zone.parse("2011-02-24 21:15"); s.venue = venue("B4") }
    screening("Black Bread", "2011-02-24 21:15") \
      {|s| s.starts = Time.zone.parse("2011-02-24 20:30"); s.venue = venue("B2") }

    # 2/25
    screening("A War in Hollywood", "2011-02-25 15:30") \
      {|s| s.starts = Time.zone.parse("2011-02-25 15:45") }
    screening("Black Bread", "2011-02-25 15:45") \
      {|s| s.starts = Time.zone.parse("2011-02-25 15:15"); s.venue = venue("WH") }
    screening("Cold Weather", "2011-02-25 18:45") \
      {|s| s.starts = Time.zone.parse("2011-02-25 18:30") }
    f = @festival.films.create!(:name => "Mutant Girls Squad",
                                :duration => 85 * 60,
                                :countries => "jp")
    @festival.screenings.create!(:film => f, :venue => venue("C21"),
                                 :starts => Time.zone.parse("2011-02-25 23:30"),
                                 :ends => Time.zone.parse("2011-02-25 23:30") + f.duration,
                                 :press => false)

    v = @festival.venues.create!(:name => "Newmark Theatre",
                                 :group => "Newmark Theatre",
                                 :abbrev => "NT")
    f = @festival.films.create!(:name => "Potiche",
                                :duration => 103 * 60,
                                :countries => "fr")
    @festival.screenings.create!(:film => f, :venue => v,
                                 :starts => Time.zone.parse("2011-02-10 19:30"),
                                 :ends => Time.zone.parse("2011-02-10 19:30") + f.duration,
                                 :press => false)

    v = @festival.venues.create!(:name => "Fields Ballroom",
                                 :group => "Fields Ballroom",
                                 :abbrev => "FB")
    f = @festival.films.create!(:name => "Closing Party",
                                :duration => 120 * 60)
    @festival.screenings.create!(:film => f, :venue => v,
                                 :starts => Time.zone.parse("2011-02-26 21:30"),
                                 :ends => Time.zone.parse("2011-02-26 21:30") + f.duration,
                                 :press => false)
    @festival.revised_at = Time.zone.parse("2011-01-29 00:00")
    @festival.save!
  end

  def venue(abbrev)
    result = @festival.venues.find_by_abbrev!(abbrev)
    if block_given?
      yield result
      result.save!
    end
    result
  end

  def film(film_name)
    result = @festival.films.find_by_name!(film_name)
    if block_given?
      yield result
      result.save!
    end
    result
  end

  def screening(film_name, screening_time)
    result = film(film_name).screenings.find_by_starts!(Time.zone.parse(screening_time))
    if block_given?
      yield result
      result.save!
    end
    result
  end
  
  def process_row
    return if @values.all? {|k, v| v.nil? } # blank row!?
    
    # Make sure we have this venue
    venue = find_or_create_venue

    # Make sure we have this film
    film = find_or_create_film

    # Create this screening
    starts = Time.zone.parse("#{@values[:date]} #{@values[:time]}")
    ends = starts + film.duration
    abort "Screening times (#{starts} - #{ends}) outside festival (#{@festival.starts} - #{@festival.ends})" \
      unless starts.to_date >= (@festival.starts - 3) and \
                 ends.to_date <= (@festival.ends + 3) and \

    screening = @festival.screenings.create!(:film => film,
      :venue => venue, :starts => starts, :ends => ends,
      :press => false)
    puts "Made screening #{screening.inspect}"
  end


  def find_or_create_venue
    name = @values[:venue]
    abort "no venue name in #{@values.inspect}" if name.blank?
    name.strip!
    @venues[name] ||= begin
      abbrev = case name
      when "Cinemagic"
        "CM"
      when "Hollywood Theatre"
        "HW"
      when "Whitsell Auditorium"
        "WH"
      else
        initial = name[0..0]
        number = /(\d+)/.match(name)[1] rescue name.split(' ')[1][0..0].upcase
        number.strip!
        "#{initial}#{number}"
               end
      group = (name =~ /Broadway/) ? "Broadway" : name

      puts "making venue #{name}, #{abbrev}, #{group}"
      v = @festival.venues.create!(:name => name, :abbrev => abbrev,
                                   :group => group)
      # puts "Made venue #{v.inspect}"
      v
    end
  end

  def find_or_create_film
    name = @values[:title]
    @films[name] ||= begin
      title = convert_case(name)
      duration = extract_duration
      countries = extract_countries
      f = @festival.films.create!(:name => title,
        :duration => duration,
        :countries => countries)
      puts "Made film  #{f.inspect}"
      f
    end
  end

  def parse_keys(row)
    keys = {}
    row.each_with_index do |key, index|
      keys[index] = key.downcase.gsub(' ','_').to_sym
    end
    keys
  end
 
  def parse_values(row)
    values = {}
    row.each_with_index do |value, index|
      values[@keys[index]] = value
    end
    values
  end

  @@special_titles = {
    "MID-AUGUST LUNCH" => "Mid-August Lunch",
    "REYKJAVIK-ROTTERDAM" => "Reykjavik-Rotterdam",
    "THE LETTER FOR THE KING" => "The Letter for the King",
    "THE GIRL ON THE TRAIN" => "The Girl on the Train",
    "REMBRANDT\222S J\222ACCUSE" => "Rembrandt's J'accuse",
    "WARD NO. 6" => "Ward No. 6",
    "LEARNING FROM LIGHT: THE VISION OF I.M. PEI" =>
      "Learning from Light: The Vision of I.M. Pei",
    "OPENING NIGHT FILM AND PARTY" =>
      "I Am Love"
  }
  def convert_case(title)
    if result = @@special_titles[title]
      return result
    end

    words = []
    title.split.each_with_index do |word, index|
      if %w[A AND IN THE OF].include?(word) and index != 0
        word.downcase!
      elsif /^[IVX]+:$/.match(word).nil? and /\.$/.match(word).nil?
        word = word.downcase.camelize
      end
      word = "International Ties" if word == "Internationalties"
      words << word
    end
    words.join(' ')
  end

  def extract_duration
    result = if @values[:title] == "CLOSING PARTY"
      60
    elsif @values[:title] == "OPENING NIGHT FILM AND PARTY"
      120
    elsif @values[:description].\
            match(/Total program running time: (\d+) mins\./)
      $~[1].to_i
    else
      # 2011: weird character separating the time; filter it out.
      durations = @values[:description].gsub(/\xca/,' ').scan(/\((\d+) mins?\.\)/)
      durations.inject(0) do |total, minutes|
        minutes = minutes[0].to_i
        total + minutes
      end
    end
    abort "Can't determine duration" if result == 0
    result * 60
  end

  def extract_countries
    return nil if @values[:description].scan(/\((\d+) mins?\.\)/).count > 1
    country_names = /^([^\<]+)/.match(@values[:description])[1].split('/')
    country_codes = country_names.map do |name|
      name = name.downcase.split(' ').map(&:camelize).join(' ')
      name = "Great Britain" if ["United Kingdom", "Great Britan"].include?(name)
      name = "Colombia" if name == "Columbia"
      code = Countries.name_to_code(name)
      debugger if code.blank? and \
       !["OPENING NIGHT FILM AND PARTY", "CLOSING PARTY"]\
       .include?(@values[:title])
      code
    end
    country_codes.join(' ')
  end
end

desc "Load data from a PIFF csv"
task :piff => :environment do
  require 'csv'
  require 'ruby-debug'

  ActiveRecord::Base.transaction do
    festival = Festival.find_by_slug("piff_2011")
    abort "Festival already has venues - aborting" \
      unless festival.venues.empty?

    PIFFCSV.new(Festival.find_by_slug("piff_2011")).load

    # raise ActiveRecord::Rollback
  end
end
