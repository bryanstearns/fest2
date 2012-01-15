require 'ruby-debug'

class ChangesFor2012 < ActiveRecord::Migration
  def self.up
    add_index :screenings, :film_id

    say_with_time("Changing pick values to powers of two") do
      Pick.find_each do |p|
        if p.priority == 3
          p.priority = 4
          p.save!
        elsif p.priority == 4
          p.priority = 8
          p.save!
        end
      end
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
        puts "  #{venue.festival.name} / #{venue.name} --> '#{group_name}'"
        h[[venue.festival.name, group_name]] << venue
        h
      end
      groups.each do |(festival_name, name), venues|
        location = venues.first.festival.locations.create!(:name => name, :venues => venues)
        venues.each do |venue|
          venue.location_id = location.id
          venue.save!
        end
      end
    end

    remove_column :venues, :group
  end

  def self.down
    drop_table :locations
  end
end
