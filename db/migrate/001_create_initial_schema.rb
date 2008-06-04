class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :session_id
      t.text :data
      t.timestamps
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    create_table :users, :force => true do |t|
      t.string :login, :email
      t.string :crypted_password, :salt, :limit => 40
      # Already added in anticipation of OpenID support...
      t.string :identity_url, :remember_token
      t.datetime :remember_token_expires_at
      t.boolean :admin, :default => false
      t.timestamps
    end

    create_table :festivals do |t|
      t.string :name, :slug, :location, :url, :film_url_format
      t.date :starts, :ends
      t.boolean :public, :scheduled, :default => false
      t.timestamps
    end
    
    create_table :subscriptions do |t|
      t.integer :festival_id, :user_id, :null => false
      t.boolean :admin, :default => false
    end

    create_table :venues do |t|
      t.integer :festival_id, :null => false
      t.string :name, :abbrev
    end

    create_table :films do |t|
      t.integer :festival_id, :null => false
      t.string :name, :description, :url_fragment
      t.integer :duration
      t.timestamps
    end

    create_table :screenings do |t|
      t.integer :festival_id, :film_id, :venue_id, :null => false
      t.datetime :starts, :ends, :null => false
      t.timestamps
    end

    create_table :picks do |t|
      t.integer :user_id, :film_id, :festival_id, :null => false
      t.integer :screening_id, :null => true
      t.integer :priority, :null => true
    end
    
    create_table :announcements do |t|
      t.string :subject, :contents, :null => false
      t.boolean :published, :default => false
      t.datetime :published_at
      t.timestamps
    end
  end

  def self.down
    drop_table :picks
    drop_table :screenings
    drop_table :films
    drop_table :venues
    drop_table :subscriptions
    drop_table :festivals
    drop_table :users
    drop_table :sessions
  end
end
