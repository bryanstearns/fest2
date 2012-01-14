class VenueGroup < ActiveRecord::Base
  belongs_to :festival
  has_many :venues, :dependent => :destroy, :foreign_key => :group_id
end
