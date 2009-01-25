require File.dirname(__FILE__) + '/../spec_helper'

context "A Restriction" do
  it "should detect conflicts" do
    a = Restriction.new(10.minutes.ago, 5.minutes.ago)
    b = Restriction.new(7.minutes.ago, 2.minutes.ago)
    c = Restriction.new(4.minutes.ago, 2.minutes.ago)
    a.overlaps?(b).should == true
    a.overlaps?(c).should == false
    b.overlaps?(c).should == true
  end

  it "should convert itself to YAML" do
    t = DateTime.new(2001, 1, 1, 12, 0)
    Restriction.new(t, t + 10.minutes).to_yaml.should == \
      "--- !ruby/object:Restriction \nends: 2001-01-01T12:10:00+00:00\nstarts: 2001-01-01T12:00:00+00:00\n"
  end
end
