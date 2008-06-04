require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
  end

  it "should be valid if complete" do
    @question.should_not be_valid
    @question.email = "bob@example.com"
    @question.question = "what's the capitol of South Dakota?"
    @question.should be_valid
  end
end
