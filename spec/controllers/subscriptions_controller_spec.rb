require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionsController do
  include AdminUserSpecHelper
  
  def make_festival
    @festival = mock_model(Festival, :public => true, :to_param => "1", :is_conference => false, :id => 1)
    Festival.stub!(:find_by_slug).and_return(@festival)
  end

  describe "in general," do
    before { make_festival }    
    %w(create new edit show update destroy).each do |action|
      it "should require login for #{action}" do
        require_login action, :festival_id => "1"
      end
    end
  end

=begin
  describe "when logged in," do
    def make_subscription
      @subscription = mock_subscription(Subscription,
        :user_id => ordinary_user.id, :festival_id => @festival.id)
    end
    
    before(:each) do
      make_festival
      login_as ordinary_user
      make_subscription
    end

    describe "handling GET /festivals/1/settings" do

      def do_get
        get :show, :festival_id => 1
      end

      it "should be successful" do
        do_get
        response.should be_success
      end
  
      it "should render show template" do
        do_get
        response.should render_template('show')
      end
  
      it "should find the subscription requested" do
        current_user.should_receive(:subscription_for).with(1).and_return(@subscription)
        do_get
      end
  
      it "should assign the found film for the view" do
        do_get
        assigns[:subscription].should equal(@subscription)
      end
    end

    describe "handling GET /festivals/1/settings.xml" do
      before(:each) do
        @subscription.stub!(:to_xml).and_return("XML")
      end
  
      def do_get
        @request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :festival_id => "1"
      end

      it "should be successful" do
        do_get
        response.should be_success
      end
  
      it "should find the subscription requested" do
        current_user.should_receive(:subscription_for).with(1).and_return(@subscription)
        do_get
      end
  
      it "should render the found film as xml" do
        @subscription.should_receive(:to_xml).and_return("XML")
        do_get
        response.body.should == "XML"
      end
    end

    describe "handling GET /festivals/1/settings/edit" do

      before(:each) do
        login_as admin_user
        make_festival_and_film
      end
    
      def do_get
        get :edit, :festival_id => "1", :id => "1"
      end

      it "should be successful" do
        do_get
        response.should be_success
      end
    
      it "should render edit template" do
        do_get
        response.should render_template('edit')
      end
    
      it "should find the film requested" do
        @films.should_receive(:find).and_return(@film)
        do_get
      end
    
      it "should assign the found Film for the view" do
        do_get
        assigns[:film].should equal(@film)
      end
    end

    describe "handling PUT /festivals/1/films/1" do

      before(:each) do
        login_as admin_user
        make_festival_and_film
        @film.stub!(:update_attributes).and_return(true)
      end
    
      it "should fail if ordinary html requested" do
        lambda {put :update, :id => "1", :festival_id => 1}.should raise_error(NonAjaxEditsNotSupported)
      end

#    describe "with successful update" do
#
#      def do_put
#        @film.should_receive(:update_attributes).and_return(true)
#        put :update, :id => "1", :festival_id => "1"
#      end
#
#      it "should find the film requested" do
#        @films.should_receive(:find).with("1").and_return(@film)
#        do_put
#      end
#
#      it "should update the found film" do
#        do_put
#        assigns(:film).should equal(@film)
#      end
#
#      it "should assign the found film for the view" do
#        do_put
#        assigns(:film).should equal(@film)
#      end
#
#      it "should redirect to the film" do
#        do_put
#        response.should redirect_to(festival_film_url("1", "1"))
#      end
#
#    end
#    
#    describe "with failed update" do
#
#      def do_put
#        @film.should_receive(:update_attributes).and_return(false)
#        put :update, :id => "1"
#      end
#
#      it "should re-render 'edit'" do
#        do_put
#        response.should render_template('edit')
#      end
#
#    end
    end
  end
=end
end
