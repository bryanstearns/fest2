require File.dirname(__FILE__) + '/../../spec_helper'

describe "/buzz/edit.html.erb" do
  include BuzzHelper

  before(:each) do
    assigns[:buzz] = @buzz = stub_model(Buzz,
      :new_record? => false,
      :film_id => 1,
      :user_id => 1,
      :content => "value for content",
      :url => "value for url"
    )
    assigns[:film] = stub_model(Film, :id => "1")    
  end

  it "renders the edit buzz form" do
    render

    response.should have_tag("form[action=#{buzz_path(@buzz)}][method=post]") do
      with_tag('input#buzz_film_id[name=?]', "buzz[film_id]")
      with_tag('input#buzz_user_id[name=?]', "buzz[user_id]")
      with_tag('textarea#buzz_content[name=?]', "buzz[content]")
      with_tag('input#buzz_url[name=?]', "buzz[url]")
    end
  end
end
