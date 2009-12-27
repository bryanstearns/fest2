require File.dirname(__FILE__) + '/../../spec_helper'

describe "/announcements/show.html.erb" do
  include AnnouncementsHelper
  
  before(:each) do
    @announcement = mock_model(Announcement, :subject => "subj",
      :contents => "contents", :published => true, 
      :published_at => Date.today)

    assigns[:announcement] = @announcement
  end

  it "should render attributes in <p>" do
    render "/announcements/show.html.erb"
  end
end

