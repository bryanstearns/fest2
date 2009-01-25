
class Restriction
  attr_accessor :starts, :ends

  def initialize(starts, ends)
    @starts = starts
    @ends = ends
  end

  def overlaps?(other)
    (starts < other.ends) and (ends > other.starts)
  end
end
