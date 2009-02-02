class Restriction
  attr_accessor :starts, :ends

  def initialize(starts, ends=nil)
    @starts = starts
    @ends = ends || starts.end_of_day
  end

  def overlaps?(other)
    (starts < other.ends) and (ends > other.starts)
  end

  def ==(other)
    (starts == other.starts) and (ends == other.ends)
  end

  def inspect
    "<Restriction #{starts}-#{ends}>"
  end

  def to_text
    result = "#{starts.month}/#{starts.day}"
    return result if (starts.seconds_since_midnight == 0 and \
                      ends.seconds_since_midnight == 86399.0)
    starts_text = format_time(starts, 0)
    ends_text = format_time(ends, 86399)
    "#{result} #{starts_text}-#{ends_text}"
  end

  def format_time(t, default=nil)
    return "" if t.seconds_since_midnight == default
    hour = t.hour % 12
    return t.strftime("#{hour}%P") if t.min == 0
    t.strftime("#{hour}:%M%P")
  end

  def self.parse(text, context_date=nil)
    context_date ||= Time.zone.now
    context_date = context_date.to_date
    text = text.gsub(%r/\s{2,}/, ' ')
    text.split(",").map {|raw| parse_one_day(raw, context_date)}.flatten
  end

  def self.parse_one_day(text, context_date)
    date_text, times_text = text.split(' ', 2)
    raise(ArgumentError, "Invalid date: '#{date_text}'") \
      unless date_text =~ %r/^\d\d?\/\d\d?$/
    date = Time.zone.parse(date_text.strip, context_date)
    raise(ArgumentError, "Invalid date: '#{date_text}'") unless date
    diff = context_date - date.to_date
    if diff > 300
      date += 1.year
    elsif diff < -300
      date -= 1.year
    end
    parse_time_ranges(times_text, date) do |starts, ends|
      Restriction.new(starts, ends)
    end
  end

  def self.parse_time_ranges(times_text, date)
    times_text = "0:00-23:59:59" if times_text.nil? or times_text.blank?
    results = []
    times_text.split('&').each do |range_text|
      starts_text, ends_text = range_text.strip.split('-')
      starts = parse_time(starts_text, date, "0:00")
      ends = parse_time(ends_text, date, "23:59:59")
      result = block_given? ? yield(starts, ends) : [starts, ends]
      results << result
    end
    results
  end

  def self.parse_time(time_text, date, default="0:00")
    text = time_text.blank? ? default : time_text.strip
    raise(ArgumentError, "Invalid time: '#{time_text}'") \
      unless text =~ %r/^\d\d?(:\d\d(:\d\d)?)?\s?(am|pm)?$/
    text += ":00" if text =~ %r/^\d+$/
    begin
      parsed = Time.zone.parse(text, date)
    rescue
      raise(ArgumentError, "Invalid time: '#{time_text}'")
    end
    raise(ArgumentError, "Invalid time: '#{time_text}'") \
      unless parsed
    parsed
  end

  def self.to_text(restrictions)
    return "" unless restrictions
    restrictions.map(&:to_text).join(", ")
  end
end
