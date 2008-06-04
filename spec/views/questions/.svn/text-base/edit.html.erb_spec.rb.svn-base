require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/edit.html.erb" do
  include QuestionsHelper
  
  before do
    @question = mock_model(Question, :email => "x", :question => "y", :done => false, :acknowledged => false)
    assigns[:question] = @question
  end

  it "should render edit form" do
    render "/questions/edit.html.erb"

    response.should have_tag("form[action=?][method=post]", question_path(@question)) do
    end
  end
end


