class RemoveFilmAsin < ActiveRecord::Migration
  def self.up
    remove_column :films, :amazon_data
    remove_column :films, :amazon_ad
    remove_column :films, :amazon_url
  end

  def self.down
  end
end
