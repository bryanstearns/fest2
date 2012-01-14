class Venue < CachedModel
  before_destroy :no_screenings?

  belongs_to :festival
  belongs_to :group, :class_name => "VenueGroup"
  has_many :screenings
  validates_presence_of :name, :abbrev, :festival
  validates_uniqueness_of :name, :abbrev, :scope => :festival_id

  def no_screenings?
    screenings.count == 0
  end

  #def group
  #  read_attribute(:group) || name
  #end
  #
  #def group_key
  #  group.downcase.underscore.gsub(' ','_').gsub(/[^a-z0-9_]/, '').to_sym
  #end
end
