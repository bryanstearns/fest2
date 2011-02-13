require File.dirname(__FILE__) + '/../../spec_helper'

describe "/announcements/edit.html.erb" do
  include AnnouncementsHelper
  
  before do
    @announcement = mock_model(Announcement, :subject=>"subject", :contents=> "contents",
                               :published => true, :published_at => Time.zone.now)
    assigns[:announcement] = @announcement
  end

  it "should render edit form" do
    render "/announcements/edit.html.erb"
    
    response.should have_tag("form[action=#{announcement_path(@announcement)}][method=post]") do
    end
  end
end


