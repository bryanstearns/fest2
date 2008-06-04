class FixTextColumns < ActiveRecord::Migration
  def self.up
    change_column "announcements", "contents", :text
    change_column "films", "description", :text
    change_column "questions", "question", :text
  end

  def self.down
    change_column "announcements", "contents", :string
    change_column "films", "description", :string
    change_column "questions", "question", :string
  end
end
