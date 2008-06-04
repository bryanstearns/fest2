class Question < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :question
end
