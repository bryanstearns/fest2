require File.dirname(__FILE__) + '/../../spec_helper'

describe "/buzz/new.html.erb" do
  include BuzzHelper

  before(:each) do
    assigns[:buzz] = stub_model(Buzz,
      :new_record? => true,
      :film_id => 1,
      :user_id => 1,
      :content => "value for content",
      :url => "value for url"
    )
    assigns[:film] = @film = stub_model(Film, :id => "1")
  end

  it "renders new buzz form" do
    render

    response.should have_tag("form[action=?][method=post]", film_buzz_index_path(@film)) do
      with_tag("input#buzz_film_id[name=?]", "buzz[film_id]")
      with_tag("input#buzz_user_id[name=?]", "buzz[user_id]")
      with_tag("textarea#buzz_content[name=?]", "buzz[content]")
      with_tag("input#buzz_url[name=?]", "buzz[url]")
    end
  end
end
