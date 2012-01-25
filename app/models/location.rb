class Location < ActiveRecord::Base
  belongs_to :festival
  has_many :venues, :dependent => :destroy
  has_many :screenings # destroyed by venues
  has_many :travel_intervals_1, :as => :location_1
  has_many :travel_intervals_2, :as => :location_2
end
