require File.dirname(__FILE__) + '/../../spec_helper'

describe "The welcome page" do
  before do
    assigns[:festivals] = []
    assigns[:announcements] = []
    assigns[:announcement_limit] = 2
    assigns[:amazon_films] = []
    assigns[:amazon_limit] = 2    
  end
  
  describe "logged out and without festivals" do
    before do
      # template.should_receive(:logged_in?).and_return(false)        
      render 'welcome/index'
    end
  
    #it "should contain a login box" do
      #response.should have_tag("form[action=/account/login]")
    #end
    
    it "should list no festivals" do
      response.should have_tag("p", /More .* coming soon/)
    end
  end
  
  describe "with festivals" do
    before do
      @festivals = [ 
        mock("festival", :name => "name", :location => nil, :dates => "x", 
             :starts => "0", :ends => Date.tomorrow, :scheduled => true)
      ]
      assigns[:festivals] = @festivals
    end

    it "should list the festivals" do
      template.should_receive(:render).with(:partial => 'festivals/festival',
                              :collection => @festivals)
      render 'welcome/index'
      response.should have_tag("h3", /Click an upcoming festival:/)
    end
  end

  describe "with announcements" do
    it "should list the announcements" do
      @announcements = [
        mock("announcement", :id => 1, :subject => "whoa",
             :contents => "zing", :published_at => Date.today,
             :published => true)
      ]
      assigns[:announcements] = @announcements
      assigns[:announcement_limit] = 2
      template.should_receive(:render).with(
        :partial => 'announcements/announcement',
        :collection => @announcements,
        :locals => { :announcement_limit => assigns[:announcement_limit] })
      # template.should_receive(:logged_in?).and_return(false)
      render 'welcome/index'
      response.should have_tag("ul.announcements")
    end
  end
  
  describe "with Amazon ads" do
    it "should show the ads" do
      template.should_receive(:render_random_subset_with_caching)\
              .and_return(["advertizement"])
      render 'welcome/index'
      response.should have_tag("div.ad_section", /advertizement/)
    end
  end

  describe "without Amazon ads" do
    it "should not show any ads" do
      template.should_receive(:render_random_subset_with_caching)\
              .and_return([])
      render 'welcome/index'
      response.should_not have_tag("div.ad_section")
    end
  end
end
