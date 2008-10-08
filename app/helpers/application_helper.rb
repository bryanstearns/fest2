# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def revision_info
    begin
      revision_path = Rails.root + "/REVISION"
      mod_date = File.mtime(revision_path)
      revision = File.read(revision_path)
      "#{revision[0...8]} #{mod_date.strftime("%H:%M %a, %b %d %Y").gsub(" 0"," ")}"
    rescue
      "(no revision file)"
    end
  end
end

class Time
  # Add step() to times, too
  def step(limit, step)
    v = self
    while v < limit
      yield v
      v += step
    end
  end
  
  def date
    # Get the date corresponding to this time
    Date.civil(self.year, self.month, self.day)
  end

  def parts(include_zero_minutes=true)
    # Get the parts for formatting this time, with niceties like
    # "noon" & "midnight"
    if min == 0
      if hour == 0
        return "midnight", "", ""
      elsif hour == 12
        return "noon", "", ""
      end
    end
    if hour >= 12
      suffix = " pm"
      h = hour - (hour > 12 ? 12 : 0)
    else
      suffix = " am"
      h = hour == 0 ? 12 : hour
    end
    m = ":#{strftime("%M")}" if min != 0 or include_zero_minutes
    [h, m, suffix]
  end

  def to_time_label(include_zero_minutes=true)
    return parts(include_zero_minutes).join("")
  end

  def roundDown
    # Return ourself, rounded down to next hour
    return self if min % 60 == 0 # already at an hour boundary
    self - ((60 * min) + sec)
  end
  
  def roundUp
    # Return ourself, rounded up to next hour
    down = roundDown
    return self if self == down # already at an hour boundary
    down + (60 * 60)
  end
  
  def to_minutes
    # Return the number of minutes since the start of today
    (self.hour * 60) + self.min
  end
end

class Float
  def to_minutes
    (self / 60.0).to_i
  end
end

class String
  def quote(end_punctuation=nil)
    "&#8220;#{self}#{end_punctuation}&#8221;"
  end
end
