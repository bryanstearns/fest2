namespace :intervals do
  desc "Load a festival's travel intervals from a CSV"
  task :load => :environment do
    require 'ruby-debug'
    dry_run = ENV["DRY_RUN"]
    verbose = (ENV["VERBOSE"] || 0).to_i
    ActiveRecord::Base.transaction do
      festival = Festival.find_by_slug!(ENV['FESTIVAL'])
      csv = ENV['CSV'] || abort("no CSV= specified")
      locations_by_name = festival.locations.inject({}) {|h, l| h[l.name] = l; h }
      index_to_location = nil
      FasterCSV.foreach(csv) do |row|
        puts row.inspect if verbose > 2
        if index_to_location.nil? # this is the header row
          index_to_location = {}
          row.each_with_index do |name, i|
            location = locations_by_name[name]
            if location
              index_to_location[i-1] = location
            elsif !name.ends_with?(":")
              puts "Ignoring location column: #{name}" if verbose > 1
            end
          end
        else
          from_location = locations_by_name[row[0]]
          if from_location
            row[1..-1].each_with_index do |value, i|
              to_location = index_to_location[i]
              if to_location.nil?
                puts "Ignoring destination column #{i}: #{value}" if verbose > 1
              elsif (to_location.id == from_location.id)
                puts "Skipping x = x" if verbose > 2
              else
                location_ids = [from_location.id, to_location.id].sort
                interval = TravelInterval.find_or_initialize_by_festival_id_and_location_1_id_and_location_2_id(festival.id, *location_ids)
                time = value.to_i * 60.seconds
                if location_ids.first == from_location.id
                  puts "Updating #{from_location.name} #{from_location.id} -> #{to_location.name} #{to_location.id} to #{time.to_duration}" if verbose > 0
                  interval.seconds_from = time
                else
                  puts "Updating #{to_location.name} #{to_location.id} <- #{from_location.name} #{from_location.id} to #{time.to_duration}" if verbose > 0
                  interval.seconds_to = time
                end
                interval.save!
              end
            end
          else
            puts "Ignoring location row: #{row[0]}" if verbose > 1
          end
        end
      end
      if dry_run
        puts "... dry run, rolling back."
        raise ActiveRecord::Rollback
      end
    end
  end

  desc "Dump a festival's travel intervals to a CSV"
  task :dump => :environment do
    festival = Festival.find_by_slug!(ENV['FESTIVAL'])
    csv_path = ENV['CSV']
    csv_path = "#{festival.slug}_travel_times.csv" if csv_path == "1"
    csv = File.open(csv_path, 'w') if csv_path
    begin
      user = User.find_by_email(ENV['USER']) if ENV['USER']
      cache = festival.travel_intervals.make_cache(user.try(:id))
      locations = festival.locations.all(:order => 'name').to_a
      labels = ['minutes from v to:'] + locations.map(&:name)
      widths = labels.map {|l| l.length }
      format = widths.map {|w| "%#{w + 2}s" }.join('  ')
      puts(format % labels)
      csv.puts(labels.to_csv) if csv
      locations.each do |from_location|
        values = [from_location.name] + locations.map do |to_location|
          (cache.between(from_location, to_location) / 60)
        end
        puts(format % values)
        csv.puts(values.to_csv) if csv
      end
    ensure
      csv.close if csv
    end
  end
end
