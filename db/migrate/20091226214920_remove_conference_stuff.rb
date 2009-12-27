class RemoveConferenceStuff < ActiveRecord::Migration
  def self.up
    Announcement.all(:conditions => ['for_conference = ? and for_festival = ?',
                                      true, false]).map(&:destroy)
    Festival.all(:conditions => ['is_conference = ?', true]).map(&:destroy)

    remove_column :announcements, :for_festival
    remove_column :announcements, :for_conference
    remove_column :festivals, :is_conference
  end

  def self.down
  end
end
