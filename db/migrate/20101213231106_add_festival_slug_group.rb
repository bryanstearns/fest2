class AddFestivalSlugGroup < ActiveRecord::Migration
  def self.up
    add_column :festivals, :slug_group, :string

    Festival.all.each do |f|
      f.slug_group = f.slug.split('_').first
      f.save!
    end
  end

  def self.down
    remove_column :festivals, :slug_group, :string
  end
end
