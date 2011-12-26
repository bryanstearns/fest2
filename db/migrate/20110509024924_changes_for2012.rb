class ChangesFor2012 < ActiveRecord::Migration
  def self.up
    add_index :screenings, :film_id
  end

  def self.down
  end
end
