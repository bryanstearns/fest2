class Location < ActiveRecord::Base
  belongs_to :festival
  has_many :venues, :dependent => :destroy
end
