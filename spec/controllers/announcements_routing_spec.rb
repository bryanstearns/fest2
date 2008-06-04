require File.dirname(__FILE__) + '/../spec_helper'

describe AnnouncementsController do
  describe "route generation" do

    it "should map { :controller => 'announcements', :action => 'index' } to /announcements" do
      route_for(:controller => "announcements", :action => "index").should == "/announcements"
    end
  
    it "should map { :controller => 'announcements', :action => 'new' } to /announcements/new" do
      route_for(:controller => "announcements", :action => "new").should == "/announcements/new"
    end
  
    it "should map { :controller => 'announcements', :action => 'show', :id => 1 } to /announcements/1" do
      route_for(:controller => "announcements", :action => "show", :id => 1).should == "/announcements/1"
    end
  
    it "should map { :controller => 'announcements', :action => 'edit', :id => 1 } to /announcements/1/edit" do
      route_for(:controller => "announcements", :action => "edit", :id => 1).should == "/announcements/1/edit"
    end
  
    it "should map { :controller => 'announcements', :action => 'update', :id => 1} to /announcements/1" do
      route_for(:controller => "announcements", :action => "update", :id => 1).should == "/announcements/1"
    end
  
    it "should map { :controller => 'announcements', :action => 'destroy', :id => 1} to /announcements/1" do
      route_for(:controller => "announcements", :action => "destroy", :id => 1).should == "/announcements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'announcements', action => 'index' } from GET /announcements" do
      params_from(:get, "/announcements").should == {:controller => "announcements", :action => "index"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'new' } from GET /announcements/new" do
      params_from(:get, "/announcements/new").should == {:controller => "announcements", :action => "new"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'create' } from POST /announcements" do
      params_from(:post, "/announcements").should == {:controller => "announcements", :action => "create"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'show', id => '1' } from GET /announcements/1" do
      params_from(:get, "/announcements/1").should == {:controller => "announcements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'edit', id => '1' } from GET /announcements/1;edit" do
      params_from(:get, "/announcements/1/edit").should == {:controller => "announcements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'update', id => '1' } from PUT /announcements/1" do
      params_from(:put, "/announcements/1").should == {:controller => "announcements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'announcements', action => 'destroy', id => '1' } from DELETE /announcements/1" do
      params_from(:delete, "/announcements/1").should == {:controller => "announcements", :action => "destroy", :id => "1"}
    end
  end
end