require File.dirname(__FILE__) + '/../spec_helper'
require 'ruby-debug'

include RandomSubsetHelper

describe RandomSubsetHelper do
  context "when picking from a collection" do
    before do
      @collection = [0,1,2,3,4]
    end
      
    it "should return a subset of the collection" do
      stub!(:rand).and_return(2)
      random_subset(@collection, 2).should == [2,3]
    end
    it "should return a subset of the collection and wrap correctly" do
      stub!(:rand).and_return(4)
      random_subset(@collection, 3).should == [4,0,1]
    end
    it "should return the whole collection if the count's too small" do
      random_subset(@collection, @collection.size + 1).should == @collection
    end
  end
end


