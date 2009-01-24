class AddVipToScreening < ActiveRecord::Migration
  def self.up
    add_column "screenings", "vip", :boolean, :default => false
    execute "update screenings set vip = 0"
  end

  def self.down
    remove_column "screenings", "vip"
  end
end
