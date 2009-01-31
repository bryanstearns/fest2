class Restriction
  attr_accessor :starts, :ends

  def initialize(starts, ends=nil)
    @starts = starts
    @ends = ends || starts + 1.day
  end

  def overlaps?(other)
    (starts < other.ends) and (ends > other.starts)
  end

  def ==(other)
    (starts == other.starts) and (ends == other.ends)
  end

  def to_s
    "#{starts.month}/#{starts.day}"
  end

  def inspect
    "<Restriction #{starts}-#{ends}>"
  end

  def self.parse(str, context_date=nil)
    context_date ||= Time.zone.now
    str.split(",").map {|raw| parse_one_day(raw, context_date)}.flatten
  end

  def self.parse_one_day(str, context_date)
    date = Time.zone.parse(str.strip, context_date)
    raise(ArgumentError, "Invalid date: '#{str}'") unless date
    diff = context_date.to_date - date.to_date
    if diff > 6.months
      date += 1.year
    elsif diff < -6.months
      date -= 1.year
    end
    Restriction.new(date, date+1.day)
  end
end
