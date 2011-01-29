class RenameTimeRestrictionBackToRestriction < ActiveRecord::Migration
  def self.up
    rename_column :subscriptions, :time_restrictions, :restrictions
  end

  def self.down
  end
end
