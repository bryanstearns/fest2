class Announcement < CachedModel
  named_scope :unlimited, :conditions => [], :order => "published_at desc"
  named_scope :published, :conditions => ['published = ?', true], :order => "published_at desc"
end
