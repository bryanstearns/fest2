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
    t = Time.zone.local(2001, 1, 1, 12, 0)
    Restriction.new(t, t + 10.minutes).to_yaml.should == \
      "--- !ruby/object:Restriction \nends: 2001-01-01 12:10:00 Z\nstarts: 2001-01-01 12:00:00 Z\n"
  end
end

context "Generating strings from a restriction specification" do
  it "should generate correctly" do
    t = Time.zone.local(2000, 12, 18)
    Restriction.new(t).to_s.should == "12/18"
  end
end

context "Parsing a Restriction specification" do
  it "should parse whole dates (with context just before a year boundary)" do
    now = Time.zone.local(2000, 12, 18)
    result = Restriction.parse("12/28, 1/6", now)
    result.should == [
      Restriction.new(Time.zone.local(now.year, 12, 28)),
      Restriction.new(Time.zone.local(now.year+1, 1, 6))
    ]
  end
  it "should parse whole dates (with context just after a year boundary)" do
    now = Time.zone.local(2001, 1, 1)
    result = Restriction.parse("12/28, 1/6", now)
    result.should == [
      Restriction.new(Time.zone.local(now.year-1, 12, 28)),
      Restriction.new(Time.zone.local(now.year, 1, 6))
    ]
  end

  it "should raise the right exception when given something unparseable" do
    assert_raise(ArgumentError) { Restriction.parse("2/5, foobar") }
  end
end
