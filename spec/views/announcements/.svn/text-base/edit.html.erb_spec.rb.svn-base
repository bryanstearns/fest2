require File.dirname(__FILE__) + '/../../spec_helper'

describe "/announcements/edit.html.erb" do
  include AnnouncementsHelper
  
  before do
    @announcement = mock_model(Announcement, :subject=>"subject", :contents=> "contents",
                               :for_festival => true, :for_conference => false,
                               :published => true, :published_at => DateTime.now)
    assigns[:announcement] = @announcement
  end

  it "should render edit form" do
    render "/announcements/edit.html.erb"
    
    response.should have_tag("form[action=#{announcement_path(@announcement)}][method=post]") do
    end
  end
end


