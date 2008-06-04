class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  
  validates_presence_of :festival_id
  validates_presence_of :user_id
end
