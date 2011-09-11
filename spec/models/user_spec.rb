require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :users, :festivals, :screenings, :subscriptions

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it 'requires username' do
    lambda do
      u = create_user(:username => nil)
      u.errors.on(:username).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'disallows blocked email domains' do
    ["tom.com", "foo.tom.com"].each do |domain|
      lambda do
        u = create_user(:email => "foo@#{domain}")
        u.errors.on(:email).should_not be_nil
      end.should_not change(User, :count)
    end
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin@example.com', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    User.authenticate('quentin2@example.com', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin@example.com', 'test').should == users(:quentin)
  end

  it 'rejects user with blocked email' do
    User.stub!(:email_blocked?).and_return(true)
    User.authenticate('quentin@example.com', 'test').should be_nil
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two years' do
    before = 2.years.from_now.utc
    users(:quentin).remember_me
    after = 2.years.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it "returns nil when subscription doesn't exist" do
    assert Subscription.find_by_user_id_and_festival_id(
      users(:quentin).id, festivals(:intermonth)).nil?
    assert users(:quentin).subscription_for(festivals(:intermonth)).nil?
  end

  it "can create a subscription when subscription doesn't exist" do
    assert Subscription.find_by_user_id_and_festival_id(
      users(:quentin).id, festivals(:interyear)).nil?
    assert users(:quentin).subscription_for(festivals(:interyear), 
                                            :create => true)
  end

  it "finds existing subscription" do
    assert Subscription.find_by_user_id_and_festival_id(
      users(:quentin).id, festivals(:intramonth))
    assert users(:quentin).subscription_for(festivals(:intramonth))
  end

  it "handles time restrictions" do
    assert users(:quentin).can_see?(screenings(:early_two))
    assert !users(:quentin).can_see?(screenings(:early_one)) # restricted time
  end

  it "handles press-screening restrictions" do
    assert users(:aaron).can_see?(screenings(:late_one)) # press
    assert !users(:quentin).can_see?(screenings(:late_one)) # not press
  end

protected
  def create_user(options = {})
    record = User.new({ :username => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
