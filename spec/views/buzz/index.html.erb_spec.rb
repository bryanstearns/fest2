require File.dirname(__FILE__) + '/../../spec_helper'

describe "/buzz/index.html.erb" do
  include BuzzHelper

  before(:each) do
    assigns[:buzz] = [
      stub_model(Buzz,
        :film_id => 1,
        :user_id => 1,
        :content => "value for content",
        :url => "value for url"
      ),
      stub_model(Buzz,
        :film_id => 1,
        :user_id => 1,
        :content => "value for content",
        :url => "value for url"
      )
    ]
    assigns[:film] = stub_model(Film, :id => "1")
  end

  it "renders a list of buzz" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for content".to_s, 2)
    response.should have_tag("tr>td", "value for url".to_s, 2)
  end
end
