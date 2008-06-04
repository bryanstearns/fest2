class AddModeFlags < ActiveRecord::Migration
  def self.up
    add_column "festivals", "is_conference", :boolean, :default => false
    add_column "announcements", "for_conference", :boolean, :default => false
    add_column "announcements", "for_festival", :boolean, :default => false
    execute "update announcements set for_festival = published"
  end

  def self.down
    remove_column "festivals", "is_conference"
    remove_column "announcements", "for_conference"
    remove_column "announcements", "for_festival"
  end
end
