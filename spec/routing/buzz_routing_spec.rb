require File.dirname(__FILE__) + '/../spec_helper'

describe BuzzController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/films/1/buzz" }.should route_to(:controller => "buzz", :action => "index", :film_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/films/1/buzz/new" }.should route_to(:controller => "buzz", :action => "new", :film_id => "1")
    end

    it "recognizes and generates #show" do
      { :get => "/buzz/1" }.should route_to(:controller => "buzz", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/buzz/1/edit" }.should route_to(:controller => "buzz", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/films/1/buzz" }.should route_to(:controller => "buzz", :action => "create", :film_id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/buzz/1" }.should route_to(:controller => "buzz", :action => "update", :id => "1") 
    end

#    it "recognizes and generates #destroy" do
#      { :delete => "/buzz/1" }.should route_to(:controller => "buzz", :action => "destroy", :id => "1")
#    end
  end
end
