require File.dirname(__FILE__) + '/../spec_helper'

describe Buzz do
  before(:each) do
    @valid_attributes = {
      :film_id => 1,
      :user_id => 1,
      :content => "value for content",
      :url => "value for url",
      :published_at => Time.zone.now
    }
  end

  it "should create a new instance given valid attributes" do
    Buzz.create!(@valid_attributes)
  end
end
