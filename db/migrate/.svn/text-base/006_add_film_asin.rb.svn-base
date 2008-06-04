class AddFilmAsin < ActiveRecord::Migration
  def self.up
    # We start by setting the raw data programmatically.
    add_column :films, :amazon_data, :text
    
    # Once reviewed, one element from the data is rendered as an ad, with matching URL.
    add_column :films, :amazon_ad, :text
    add_column :films, :amazon_url, :string
  end

  def self.down
    remove_column :films, :amazon_data
    remove_column :films, :amazon_ad
    remove_column :films, :amazon_url
  end
end
