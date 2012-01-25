require File.dirname(__FILE__) + '/../spec_helper'

describe "Auto_scheduling setup" do
  fixtures :festivals, :picks, :screenings, :users, :films
  before(:each) do
    quentin = users(:quentin)
    quentin.stub!(:can_see?).and_return(true)
    @sched = AutoScheduler.new(quentin, festivals(:intramonth),
                               :now => "1996/12/1")
    #pp @sched.all_screenings
    #pp @sched.all_picks
  end

  it "should collect picks for one user" do
    @sched.all_picks.to_set.should == [
      picks(:quentin_one), 
      picks(:quentin_two), 
      picks(:quentin_three)
    ].to_set
  end

  it "should collect screening costs" do
    @sched.collect_screenings_by_cost
    @sched.screening_costs.size.should == 7
    { :early_one => nil, :early_two => nil, :early_three => nil,
      :mid_three => -1001.0,
      :late_one => nil, :late_two => nil, :late_three => nil }.each_pair do |s,c|
      @sched.screening_costs[screenings(s)].should == c
    end
  end

  it "should detect conflicts between screenings" do
    [ [ :early_one, :early_two, :early_three ],
      [ :late_one, :late_two, :late_three ] ].each do |sn|
      screening_trio = sn.map { |ss| screenings(ss) }
      screening_trio.each do |s|
        @sched.screening_conflicts[s].to_set.should == screening_trio.reject {|o| o == s}.to_set
      end
    end
  end
end

#describe "first pass" do
#  fixtures :festivals, :picks, :screenings, :users
#  before do
#    @sched = AutoScheduler.new(users(:quentin), festivals(:intramonth))
#  end
#  
#  it "should auto-schedule picked screenings without conflicts" do
#    before = @sched.prioritized_unselected_picks.size
#    @sched.pass1
#    @sched.prioritized_unselected_picks.size.should == (before - 1)
#  end
#end

#describe "second pass" do
#  fixtures :festivals, :picks, :screenings, :users
#  before do
#    @sched = AutoScheduler.new(users(:quentin), festivals(:intramonth))
#  end
#
#  it "should do something" do
#    @sched.pass2
#  end
#end
