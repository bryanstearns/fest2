class Venue < CachedModel
  belongs_to :festival
  belongs_to :location
  has_many :screenings, :dependent => :destroy
  validates_presence_of :name, :abbrev, :festival
  validates_uniqueness_of :name, :abbrev, :scope => :festival_id

  #def group
  #  read_attribute(:group) || name
  #end
  #
  #def group_key
  #  group.downcase.underscore.gsub(' ','_').gsub(/[^a-z0-9_]/, '').to_sym
  #end
end
