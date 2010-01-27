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
    CSV::Reader.parse(File.open('PIFF33.csv', 'rb')) do |row|
      if @keys.nil?
        @keys = parse_keys(row)
      elsif row != [nil]
        @values = parse_values(row)
        process_row
      end
    end
  end
  
  def process_row
    # Make sure we have this venue
    venue = find_or_create_venue

    # Make sure we have this film
    film = find_or_create_film

    # Create this screening
    starts = Time.zone.parse("#{@values[:date]} #{@values[:time]}")
    ends = starts + film.duration
    abort unless starts.to_date >= @festival.starts and \
                 ends.to_date <= @festival.ends and \

    screening = @festival.screenings.create!(:film => film,
      :venue => venue, :starts => starts, :ends => ends,
      :press => false)
    puts "Made screening #{screening.inspect}"
  end


  def find_or_create_venue
    name = @values[:venue]
    @venues[name] ||= begin
      initial = name[0..0]
      number = /(\d+)/.match(name)[1] rescue name.split(' ')[1][0..0].upcase
      abbrev = "#{initial}#{number}"
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
      durations = @values[:description].scan(/\((\d+) mins?\.\)/)
      durations.inject(0) do |total, minutes|
        minutes = minutes[0].to_i
        total + minutes
      end
    end
    result * 60
  end

  def extract_countries
    return nil if @values[:description].scan(/\((\d+) mins?\.\)/).count > 1
    country_names = /^([^\<]+)/.match(@values[:description])[1].split('/')
    country_codes = country_names.map do |name|
      name = name.downcase.split(' ').map(&:camelize).join(' ')
      name = "United Kingdom" if name == "Great Britain"
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
    festival = Festival.find_by_slug("piff_2010")
    abort "Festival already has venues - aborting" \
      unless festival.venues.empty?

    PIFFCSV.new(Festival.find_by_slug("piff_2010")).load
    # raise ActiveRecord::Rollback
  end
end
