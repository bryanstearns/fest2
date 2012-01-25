require 'ruby-debug'

class ChangesFor2012 < ActiveRecord::Migration
  def self.up
    add_index :screenings, :film_id

    say_with_time("Changing pick values to powers of two") do
      Pick.update_all({ :priority => 8 }, { :priority => 4 })
      Pick.update_all({ :priority => 4 }, { :priority => 3 })
    end

    create_table :locations do |t|
      t.string :name
      t.integer :festival_id
      t.timestamps
    end
    add_column :venues, :location_id, :integer

    say_with_time("converting venue groupings to location models") do
      Venue.reset_column_information
      fixed = ["Camera 12", "Cinema 21"]
      groups = Venue.all.inject(Hash.new {|h, k| h[k] = []}) do |h, venue|
        group_name = venue.group
        if group_name.blank?
          group_name = if !fixed.include?(venue.name) and (venue.name =~ /(.*?)\s+(VIP\s+)?\d+/)
            $1.rstrip
          else
            venue.name
          end
        end
        # puts "  #{venue.festival.name} / #{venue.name} --> '#{group_name}'"
        h[[venue.festival.name, group_name]] << venue
        h
      end
      groups.each do |(festival_name, name), venues|
        festival = venues.first.festival
        location = festival.locations.create!(:name => name, :venues => venues)
        venues.each do |venue|
          venue.location_id = location.id
          venue.save!
        end
      end
    end

    add_column :screenings, :location_id, :integer
    say_with_time("copying venues' location_id to screenings") do
      Screening.reset_column_information
      Venue.find_each do |venue|
        Screening.update_all({ :venue_id => venue.id }, { :location_id => venue.location_id })
      end
    end

    add_column :subscriptions, :excluded_location_ids, :string

    say_with_time("converting subscription venue group exclusions to use location ids") do
      Subscription.reset_column_information
      Subscription.find_each do |subscription|
        if subscription.excluded_venues.present?
          location_ids = YAML.load(subscription.excluded_venues).map do |group_name|
            group_name = group_name.to_s.titleize
            venue = Venue.find_by_festival_id_and_group(subscription.festival_id, group_name)
            venue ||= Venue.find_by_festival_id_and_name!(subscription.festival_id, group_name)
            venue.location_id
          end
          subscription.excluded_location_ids = location_ids.uniq
        end
      end
    end

    remove_column :venues, :group
    remove_column :subscriptions, :excluded_venues
    Venue.reset_column_information
    Subscription.reset_column_information

    create_table :travel_intervals do |t|
      t.references :festival, :location_1, :location_2, :null => false
      t.references :user
      t.integer :seconds_from, :seconds_to
      t.timestamps
    end
    add_index :travel_interval_uniq, [:user_id, :festival_id, :location_1_id, :location_2_id],
              :unique => true

    year = Date.today.year
    old_fest = Festival.find_by_slug("piff_#{year - 1}")

    say_with_time("Cloning piff 2011 -> 2012") do
      number = 34 + (year - 2011)

      # Load travel times into the old festival
      ENV["FESTIVAL"] = old_fest.slug
      ENV["CSV"] = "public/piff_travel_times.csv"
      Rake::Task["intervals:load"].invoke

      # Remove the stub one
      Festival.find_by_slug("piff_#{year}").try(:destroy)

      old_fest.name = "Portland International Film Festival #{year - 1}"
      old_fest.save!

      pp = old_fest.locations.create!(:name => "Pioneer Place")
      old_fest.venues.create!(:location => pp, :name => "Pioneer Place 1", :abbrev => "PP1")
      old_fest.venues.create!(:location => pp, :name => "Pioneer Place 2", :abbrev => "PP2")
      wtc = old_fest.locations.create!(:name => "World Trade Center")
      old_fest.venues.create!(:location => wtc, :name => "World Trade Center", :abbrev => "WTC")
      lt = old_fest.locations.create!(:name => "Lake Twin")
      old_fest.venues.create!(:location => lt, :name => "Lake Twin", :abbrev => "LT")
      lm = old_fest.locations.create!(:name => "Lloyd Mall")
      old_fest.venues.create!(:location => lm, :name => "Lloyd Mall 5", :abbrev => "LM5")
      old_fest.venues.create!(:location => lm, :name => "Lloyd Mall 6", :abbrev => "LM6")
      old_fest.reload

      new_fest = Festival.create!(
        :name => "Portland International Film Festival",
        :slug => "piff_#{year}",
        :location => "Portland, Oregon",
        :url => "http://festivals.nwfilm.org/piff#{number}/",
        :film_url_format => "http://festivals.nwfilm.org/piff#{number}/schedule/*/",
        :starts => "2012-02-09",
        :ends => "2012-02-25",
        :public => false,
        :scheduled => false,
        :revised_at => Time.zone.now,
        :slug_group => "piff",
        :updates_url => nil)

      location_map = {}
      old_fest.locations.each do |old_location|
        location_map[old_location.id] = new_fest.locations.create!(:name => old_location.name).id
      end
      old_fest.travel_intervals.each do |old_travel_interval|
        new_fest.travel_intervals.create!(:location_1 => new_fest.locations.find_by_name(old_travel_interval.location_1.name),
                                          :location_2 => new_fest.locations.find_by_name(old_travel_interval.location_2.name),
                                          :seconds_from => old_travel_interval.seconds_from,
                                          :seconds_to => old_travel_interval.seconds_to,
                                          :user_id => old_travel_interval.user_id)
      end
      old_fest.venues.each do |old_venue|
        new_fest.venues.create!(
          :name => old_venue.name,
          :abbrev => old_venue.abbrev,
          :location_id => location_map[old_venue.location_id]).id
      end

      old_fest.subscriptions.each do |old_subscription|
        excluded_location_ids = old_subscription.excluded_location_ids \
          ? old_subscription.excluded_location_ids.map {|id| location_map[id]} \
          : nil
        new_fest.subscriptions.create!(
          :user_id => old_subscription.user_id,
          :admin => old_subscription.admin,
          :show_press => old_subscription.show_press,
          :excluded_location_ids => excluded_location_ids)
      end
    end if old_fest
  end

  def self.down
    drop_table :locations
  end
end
