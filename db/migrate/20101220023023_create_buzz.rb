class CreateBuzz < ActiveRecord::Migration
  def self.up
    create_table :buzz do |t|
      t.integer :film_id, :null => false
      t.integer :user_id, :null => false
      t.text :content
      t.string :url
      t.datetime :published_at

      t.timestamps
    end
    add_index :buzz, [:film_id, :published_at]
  end

  def self.down
    drop_table :buzz
  end
end
