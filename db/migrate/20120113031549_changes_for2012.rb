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

    say_with_time("Cloning piff 2011 -> 2012") do
      year = Date.today.year
      number = 34 + (year - 2011)

      # Remove the stub one
      Festival.find_by_slug("piff_#{year}").try(:destroy)

      old_fest = Festival.find_by_slug("piff_#{year - 1}")
      old_fest.name = "Portland International Film Festival #{year - 1}"
      old_fest.save!

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
    end
  end

  def self.down
    drop_table :locations
  end
end
