class Venue < CachedModel
  before_destroy :no_screenings?

  belongs_to :festival
  has_many :screenings
  validates_presence_of :name, :abbrev, :festival
  validates_uniqueness_of :name, :abbrev, :scope => :festival_id

  def no_screenings?
    screenings.count == 0
  end
end
