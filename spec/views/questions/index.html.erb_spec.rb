require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/index.html.erb" do
  include QuestionsHelper
  
  before(:each) do
    question_98 = mock_model(Question, :email => "x", :question => "x", 
                             :done => false, :acknowledged => false)
    question_99 = mock_model(Question, :email => "y", :question => "y", 
                             :done => false, :acknowledged => false)

    assigns[:questions] = [question_98, question_99]
  end

  it "should render list of questions" do
    render "/questions/index.html.erb"
  end
end

