class AddRevisedAtToFestival < ActiveRecord::Migration
  def self.up
    add_column :festivals, :revised_at, :datetime
  end

  def self.down
    remove_column :festivals, :revised_at
  end
end
