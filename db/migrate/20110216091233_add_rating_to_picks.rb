class AddRatingToPicks < ActiveRecord::Migration
  def self.up
    add_column :picks, :rating, :integer
  end

  def self.down
  end
end
