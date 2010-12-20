class Buzz < ActiveRecord::Base
  belongs_to :film
  belongs_to :user

  validates_presence_of :film_id, :user_id
end
