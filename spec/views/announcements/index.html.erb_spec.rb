require File.dirname(__FILE__) + '/../../spec_helper'

describe "/announcements/index.html.erb" do
  include AnnouncementsHelper
  
  before(:each) do
    announcement_98 = mock_model(Announcement, :subject => "98", 
      :contents => "contents98", :published => true,
      :published_at => Date.today)
    announcement_99 = mock_model(Announcement, :subject => "99",
      :contents => "contents99", :published => true,
      :published_at => Date.today)
    assigns[:announcements] = [announcement_98, announcement_99]
  end

  it "should render list of announcements" do
    render "/announcements/index.html.erb"
  end
end

