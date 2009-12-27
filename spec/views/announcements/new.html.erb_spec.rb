require File.dirname(__FILE__) + '/../../spec_helper'

describe "/announcements/new.html.erb" do
  include AnnouncementsHelper
  
  before(:each) do
    @announcement = mock_model(Announcement, :subject=>"subject", :contents=> "contents",
                               :published => true, :published_at => DateTime.now)
    @announcement.stub!(:new_record?).and_return(true)
    assigns[:announcement] = @announcement
  end

  it "should render new form" do
    render "/announcements/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", announcements_path) do
    end
  end
end


