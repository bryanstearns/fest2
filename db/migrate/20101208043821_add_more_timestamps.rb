class AddMoreTimestamps < ActiveRecord::Migration
  def self.up
    [:picks, :subscriptions, :venues].each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end
  end

  def self.down
    [:picks, :subscriptions, :venues].each do |table|
      remove_column table, :created_at
      remove_column table, :updated_at
    end
  end
end
