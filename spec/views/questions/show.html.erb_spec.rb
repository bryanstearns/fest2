require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/show.html.erb" do
  include QuestionsHelper
  
  before(:each) do
    @question = mock_model(Question, :email => "x",
                           :question => "y", :done => true,
                           :acknowledged => true)

    assigns[:question] = @question
  end

  it "should render attributes in <p>" do
    render "/questions/show.html.erb"
  end
end

