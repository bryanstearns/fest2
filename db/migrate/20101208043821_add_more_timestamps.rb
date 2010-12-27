class AddMoreTimestamps < ActiveRecord::Migration
  def self.up
    [:picks, :subscriptions, :venues].each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end
    
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
  end

  def self.down
    [:picks, :subscriptions, :venues].each do |table|
      remove_column table, :created_at
      remove_column table, :updated_at
    end
  end
end
