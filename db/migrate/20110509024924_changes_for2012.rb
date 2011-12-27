class ChangesFor2012 < ActiveRecord::Migration
  def self.up
    add_index :screenings, :film_id

    Pick.each do |p|
      if p.priority == 3
        p.priority = 4
        p.save!
      elsif p.priority == 4
        p.priority = 8
        p.save!
      end
    end
  end

  def self.down
  end
end
