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

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
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

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin', 'test').should == users(:quentin)
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

  it "handles VIP restrictions" do
    assert users(:aaron).can_see?(screenings(:late_one)) # VIP
    assert !users(:quentin).can_see?(screenings(:late_one)) # not VIP
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
