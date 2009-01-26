class RenameVipToPress < ActiveRecord::Migration
  def self.up
    rename_column :screenings, :vip, :press
    rename_column :subscriptions, :vip, :show_press
  end

  def self.down
    rename_column :screenings, :press, :vip
    rename_column :subscriptions, :show_press, :vip
  end
end
