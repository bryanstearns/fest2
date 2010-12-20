require File.dirname(__FILE__) + '/../../spec_helper'

describe "/buzz/show.html.erb" do
  include BuzzHelper
  before(:each) do
    assigns[:buzz] = @buzz = stub_model(Buzz,
      :film_id => 1,
      :user_id => 1,
      :content => "value for content",
      :url => "value for url"
    )
    assigns[:film] = stub_model(Film, :id => "1")
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ content/)
    response.should have_text(/value\ for\ url/)
  end
end
