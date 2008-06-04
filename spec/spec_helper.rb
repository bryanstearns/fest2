# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

# Allow us to specify the request extension (and therefore, mime type), eg:
#   get :index, :extension => :js
# Modified from http://www.nnovation.ca/2006/12/17/rspec-rails12-and-testing-return-types
# which came from: http://blog.methodmissing.com/2006/11/22/testing-different-content-types-with-rspec/
#module ActionController
#  module TestProcess
#    # lifted from rails/actionpack/lib/action_controller/test_process.rb around line 359
#    def self.included(base)
#      %w( get post put delete head ).each do |method|
#        base.class_eval <<-EOV, __FILE__, __LINE__
#          def #{method}(action, parameters = nil, session = nil, flash = nil)
#            @request.env['REQUEST_METHOD'] = "#{method.upcase}" if defined?(@request)
#            # BJS: added:
#            @request.env['CONTENT_TYPE'] = Mime::EXTENSION_LOOKUP[(parameters.delete(:extension).to_s rescue 'html')] if defined?(@request)
#            puts "CONTENT_TYPE is #{@request.env['CONTENT_TYPE']}"
#            process(action, parameters, session, flash)
#          end
#        EOV
#      end
#    end
#  end
#end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

module RoutesHelper
  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    def check_routes routes
      describe "route generation" do
        routes.each do |options, method, path|
          it "should map #{options.inspect} to #{path}" do
            route_for(options).should == path
          end
        end
      end
    
      describe "route recognition" do
        routes.each do |options, method, path|
          it "should generate #{options.inspect} from #{method.to_s.upcase} #{path}" do
            params_from(method, path).should == options
          end
        end
      end  
    end
  end
end

require 'ruby-debug'

module ConferenceVsFestivalHelper
  def force_festival_mode
    template.should_receive(:_).any_number_of_times.and_return(mock("dictionary", :[] => "festival"))
    template.should_receive(:conference_mode).any_number_of_times.and_return(false)
  end
end

# Helpful: http://rubyforge.org/pipermail/rspec-users/2006-December/000408.html
# and: http://programmingishard.com/code/tags/rspec
module AdminUserSpecHelper  
  def admin_user(id="1")
    @user = mock_model(User, :id => id, :admin => true)
  end

  def ordinary_user(id="2")
    @user = mock_model(User, :id => id, :admin => false)
  end

  def login_as(user)
    controller.send :current_user=, user
  end
  
  def logout
    controller.send :current_user=, nil
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    def require_admin_rights_appropriately(options={})
      require_login_and_admin_user("new") { get :new, options }
      require_login_and_admin_user("create") { post :create, options }
      options = {:id => "1"}.merge(options)
      require_login_and_admin_user("destroy") { delete :destroy, options }
      require_login_and_admin_user("update") { put :update, options }
    end
      
    def require_login_and_admin_user(action, &request)
      require_login action, &request
      require_admin_user action, &request
    end
  
    def require_login(action, &request)
      specify "when calling #{action}, should redirect to the login screen if the user is not logged in" do
        logout
        instance_eval(&request)
        response.should redirect_to(login_path)
      end
    end
    
    def require_admin_user(action, &request)
      specify "when calling #{action}, should raise if the logged in User isn't an admin" do
        login_as ordinary_user
        lambda {instance_eval(&request)}.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
