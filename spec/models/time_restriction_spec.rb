require File.dirname(__FILE__) + '/../spec_helper'

describe "A Restriction" do
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
      "--- !ruby/object:Restriction \nends: 2001-01-01 20:10:00 Z\nstarts: 2001-01-01 20:00:00 Z\n"
  end
end

describe "A Restriction specification" do
  before(:each) do
    @now = Time.zone.local(2001, 1, 1)
  end

  BAD_CASES = [
    "foobar", "2/5 foobar", "2/5 1-x", "1-6", "2/6 12:66", "May 6"
  ]

  GOOD_CASES = [
    ["12/18", Time.zone.local(2000, 12, 18), nil],
    ["1/1 11am-1pm", Time.zone.local(2001, 1, 1, 11), 
                     Time.zone.local(2001, 1, 1, 13)],
    ["2/2 -2:15pm", Time.zone.local(2001, 2, 2), 
                     Time.zone.local(2001, 2, 2, 14, 15)],
    ["3/3 3pm-", Time.zone.local(2001, 3, 3, 15), 
                 Time.zone.local(2001, 3, 3, 23, 59, 59)],
    ["12/28 10am-2pm", Time.zone.local(2000, 12, 28, 10, 00),
                    Time.zone.local(2000, 12, 28, 14, 00)],
  ]

  it "should format itself as a string" do
    GOOD_CASES.each do |result, starts, ends|
      Restriction.new(starts, ends).to_text.should == result
    end
  end

  it "should parse from string" do
    GOOD_CASES.each do |result, starts, ends|
      Restriction.parse(result, @now).should == [Restriction.new(starts, ends)]
    end
  end

  it "should raise the right exception when given something unparseable" do
    BAD_CASES.each do |s|
      assert_raise(ArgumentError) do
        puts "shouldn't get #{Restriction.parse(s).inspect} from #{s.inspect}"
      end
    end
  end

  it "should parse whole dates and handle nearby year boundaries" do
    [0, 5.days].each do |adjustment|
      @now += adjustment
      result = Restriction.parse("12/28, 1/6", @now)
      result.should == [
        Restriction.new(Time.zone.local(2000, 12, 28)),
        Restriction.new(Time.zone.local(2001, 1, 6))
      ]
    end
  end
end
