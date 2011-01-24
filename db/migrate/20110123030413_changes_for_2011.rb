class ChangesFor2011 < ActiveRecord::Migration
  def self.up
    # Drop the no-longer-used sessions table
    drop_table :sessions

    # Add more timestamps to the tables that were missing them
    [:picks, :subscriptions, :venues].each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end

    # Add slug_group to festival
    add_column :festivals, :slug_group, :string

    # Change login to username
    rename_column :users, :login, :username

    # Remove the last of the amazon stuff
    remove_column :films, :amazon_data
    remove_column :films, :amazon_ad
    remove_column :films, :amazon_url

    # Add the Buzz table
    create_table :buzz do |t|
      t.integer :film_id, :null => false
      t.integer :user_id, :null => false
      t.text :content
      t.string :url
      t.datetime :published_at
      t.timestamps
    end

    # Add venue groups (and the means to exclude them from scheduling)
    rename_column :subscriptions, :restrictions, :time_restrictions
    add_column :venues, :group, :string
    add_column :subscriptions, :excluded_venues, :text

    # Add indexes
    add_index :announcements, [:published, :published_at]
    add_index :buzz, [:film_id, :published_at]
    add_index :festivals, [:starts, :public]
    add_index :festivals, [:ends, :public]
    add_index :festivals, [:slug, :public]
    add_index :festivals, [:slug_group, :public]
    add_index :films, :festival_id
    add_index :picks, [:user_id, :festival_id]
    add_index :screenings, :festival_id
    add_index :subscriptions, [:festival_id, :user_id]
    add_index :users, :email, :unique => true
    add_index :users, :username
    add_index :venues, :festival_id

    # Initialize the subscriptions and picks to the date the festival ended
    festival_ends = {}
    [Pick, Subscription].each do |klass|
      say_with_time "Initializing timestamps on #{klass.name.pluralize}" do
        klass.reset_column_information
        klass.all.each do |object|
          t = (festival_ends[object.festival_id] ||= object.festival.ends.end_of_day)
          object.created_at ||= t
          object.updated_at ||= t
          object.save!
        end
      end
    end

    say_with_time "Initializing festival slug groups" do
      Festival.reset_column_information
      Festival.all.each do |f|
        f.slug_group ||= f.slug.split('_').first
        #puts "Festival #{f.slug} gets slug group #{f.slug_group.inspect}"
        f.save!
      end
    end

    Venue.reset_column_information
    fest = Festival.find_by_slug("piff_2010")
    if fest
      say_with_time "Initializing venue groups on piff_2010" do
        fest.venues.each do |v|
          v.group = (v.name =~ /Broadway/) ? "Broadway" : v.name
          v.save!
        end
      end
    end
  end

  def self.down
    raise "can't back down"
  end
end
