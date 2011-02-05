class AddUpdatesUrlToFestival < ActiveRecord::Migration
  def self.up
    add_column :festivals, :updates_url, :string

    add_column :users, :mail_opt_out, :boolean
  end

  def self.down
  end
end
