require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users

  # BJS: Added to test mailing
  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []    
  end

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  

  

  it 'requires username on signup' do
    lambda do
      create_user(:username => nil)
      assigns[:user].errors.on(:username).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  # BJS: Added to test mailing
  it 'sends email on signup' do    
    lambda { create_user }.should change(ActionMailer::Base.deliveries, :size).by(1)
  end
  
  def create_user(options = {})
    post :create, :user => { :username => 'quire', 
      :email => 'quire@example.com', :password => 'quire', 
      :password_confirmation => 'quire' }.merge(options)
  end
end
