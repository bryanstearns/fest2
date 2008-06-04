class Venue < ActiveRecord::Base
  belongs_to :festival
  has_many :screenings
  validates_presence_of :name, :abbrev, :festival
  validates_uniqueness_of :name, :abbrev, :scope => :festival_id
end
