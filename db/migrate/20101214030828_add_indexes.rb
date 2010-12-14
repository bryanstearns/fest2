class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :announcements, [:published, :published_at]
    add_index :festivals, [:starts, :public]
    add_index :festivals, [:ends, :public]
    add_index :festivals, [:slug, :public]
    add_index :festivals, [:slug_group, :public]
    add_index :films, :festival_id
    add_index :picks, [:user_id, :festival_id]
    add_index :screenings, :festival_id
    add_index :subscriptions, [:festival_id, :user_id]
    add_index :users, :email, :unique => true
    add_index :users, :username
    add_index :venues, :festival_id

    drop_table :sessions
  end

  def self.down
  end
end
