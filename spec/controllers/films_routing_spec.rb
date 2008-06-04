require File.dirname(__FILE__) + '/../spec_helper'

describe FilmsController do
  describe "route generation" do
    before(:each) do
      @festival = mock_model(Festival, :id => 1)
    end

    it "should map { :festival_id => 1, :controller => 'films', :action => 'index' } to /festivals/1/films" do
      route_for(:festival_id => 1, :controller => "films", :action => "index").should == "/festivals/1/films"
    end
  
    it "should map { :festival_id => 1, :controller => 'films', :action => 'new' } to /festivals/1/films/new" do
      route_for(:festival_id => 1, :controller => "films", :action => "new").should == "/festivals/1/films/new"
    end
  
    it "should map { :festival_id => 1, :controller => 'films', :action => 'show', :id => 1 } to /festivals/1/films/1" do
      route_for(:festival_id => 1, :controller => "films", :action => "show", :id => 1).should == "/festivals/1/films/1"
    end
  
    it "should map { :festival_id => 1, :controller => 'films', :action => 'edit', :id => 1 } to /festivals/1/films/1/edit" do
      route_for(:festival_id => 1, :controller => "films", :action => "edit", :id => 1).should == "/festivals/1/films/1/edit"
    end
  
    it "should map { :festival_id => 1, :controller => 'films', :action => 'update', :id => 1} to /festivals/1/films/1" do
      route_for(:festival_id => 1, :controller => "films", :action => "update", :id => 1).should == "/festivals/1/films/1"
    end
  
    it "should map { :festival_id => 1, :controller => 'films', :action => 'destroy', :id => 1} to /festivals/1/films/1" do
      route_for(:festival_id => 1, :controller => "films", :action => "destroy", :id => 1).should == "/festivals/1/films/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :festival_id => 1, :controller => 'films', action => 'index' } from GET /festivals/1/films" do
      params_from(:get, "/festivals/1/films").should == {:festival_id => "1", :controller => "films", :action => "index"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'new' } from GET /festivals/1/films/new" do
      params_from(:get, "/festivals/1/films/new").should == {:festival_id => "1", :controller => "films", :action => "new"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'create' } from POST /festivals/1/films" do
      params_from(:post, "/festivals/1/films").should == {:festival_id => "1", :controller => "films", :action => "create"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'show', id => '1' } from GET /festivals/1/films/1" do
      params_from(:get, "/festivals/1/films/1").should == {:festival_id => "1", :controller => "films", :action => "show", :id => "1"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'edit', id => '1' } from GET /festivals/1/films/1/edit" do
      params_from(:get, "/festivals/1/films/1/edit").should == {:festival_id => "1", :controller => "films", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'update', id => '1' } from PUT /festivals/1/films/1" do
      params_from(:put, "/festivals/1/films/1").should == {:festival_id => "1", :controller => "films", :action => "update", :id => "1"}
    end
  
    it "should generate params { :festival_id => 1, :controller => 'films', action => 'destroy', id => '1' } from DELETE /festivals/1/films/1" do
      params_from(:delete, "/festivals/1/films/1").should == {:festival_id => "1", :controller => "films", :action => "destroy", :id => "1"}
    end
  end
end