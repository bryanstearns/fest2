class AddSubscriptionRestrictions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :vip, :boolean, :default => false
    add_column :subscriptions, :restrictions, :text
  end

  def self.down
    remove_column :subscriptions, :vip
    remove_column :subscriptions, :restrictions
  end
end
