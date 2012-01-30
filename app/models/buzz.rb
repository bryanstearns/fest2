class Buzz < ActiveRecord::Base
  belongs_to :film
  belongs_to :user

  before_save :publish

  validates_presence_of :film_id, :user_id

protected
  def publish
    self.published_at ||= Time.zone.now
  end
end
