class AddUseTravelTimeToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :use_travel_time, :boolean, :default => true
  end

  def self.down
    remove_column :subscriptions, :use_travel_time
  end
end
