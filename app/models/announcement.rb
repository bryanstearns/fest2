class Announcement < CachedModel
  named_scope :unlimited, :conditions => [], :order => "published_at desc"
  named_scope :conferences, :conditions => ['published = ? and for_conference=?', true, true], :order => "published_at desc"
  named_scope :festivals, :conditions => ['published = ? and for_festival=?', true, true], :order => "published_at desc"
  
  def targets
    if for_conference
      if for_festival
        "(both)" 
      else
        "(conference)"
      end
    elsif for_festival
      "(festival)"
    else
      "(neither)"
    end
  end
end
