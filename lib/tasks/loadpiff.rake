require 'csv'
require 'ruby-debug'

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
    whitsell = @festival.venues.find_by_abbrev("WA")
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
      else
        initial = name[0..0]
        number = /(\d+)/.match(name)[1] rescue name.split(' ')[1][0..0].upcase
        number.strip!
        "#{initial}#{number}"
      end
      puts "making venue #{name}, #{abbrev}"
      v = @festival.venues.create!(:name => name, :abbrev => abbrev)
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
      name = "United Kingdom" if ["Great Britain", "Great Britan"].include?(name)
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
  ActiveRecord::Base.transaction do
    festival = Festival.find_by_slug("piff_2011")
    abort "Festival already has venues - aborting" \
      unless festival.venues.empty?

    PIFFCSV.new(Festival.find_by_slug("piff_2011")).load

    # raise ActiveRecord::Rollback
  end
end
