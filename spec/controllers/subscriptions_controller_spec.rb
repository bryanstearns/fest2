require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionsController do
  include AdminUserSpecHelper
  
  def make_festival
    @festival = mock_model(Festival, :public => true, :scheduled => true,
      :to_param => "slug", :is_conference => false, :id => 1)
    @festival.stub!(:reset_screenings)
    Festival.stub!(:find_by_slug).and_return(@festival)
  end

  describe "in general," do
    before { make_festival }    
    require_login("update") { put :update, :festival_id => "slug", :controller => "subscriptions"}
  end

  describe "when logged in," do
    def make_subscription
      @subscription = mock(Subscription, :user_id => ordinary_user.id, 
        :festival_id => @festival.id, :unselect => "future")
      controller.current_user.stub!(:subscription_for)\
        .with(@festival, :create => true).and_return(@subscription)
    end

    def make_auto_scheduler
      @scheduler = mock(AutoScheduler)
      @scheduler.stub!(:go).and_return([1,1])
      AutoScheduler.stub!(:new).and_return(@scheduler)
    end

    before(:each) do
      make_festival
      login_as ordinary_user
      make_subscription
      make_auto_scheduler
    end

    describe "handling GET /festivals/1/settings" do
      def do_get
        get :show, :festival_id => "slug" 
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
        controller.current_user.should_receive(:subscription_for)\
          .with(@festival, :create => true).and_return(@subscription)
        do_get
      end

      it "should assign the found subscription for the view" do
        do_get
        assigns[:subscription].should == @subscription
      end
    end

    describe "handling PUT /festivals/1/films/1" do
      before(:each) do
        @film.stub!(:update_attributes).and_return(true)
      end
    
      describe "with successful update" do
        def do_put
          @subscription.should_receive(:update_attributes).and_return(true)
          put :update, :id => "1", :festival_id => "slug"
        end
  
        it "should find the subscription requested" do
          controller.current_user.should_receive(:subscription_for)\
            .with(@festival, :create => true).and_return(@subscription)
          do_put
        end

        it "should update the found subscription" do
          do_put
          assigns(:subscription).should equal(@subscription)
        end

        it "should assign the found film for the view" do
          do_put
          assigns(:subscription).should equal(@subscription)
        end

        it "should redirect to the festival when done" do
          do_put
          response.should redirect_to(festival_url(@festival))
        end
      end
    
      describe "with failed update" do
        def do_put
          @subscription.should_receive(:update_attributes).and_return(false)
          put :update, :id => "1", :festival_id => "slug"
        end

        it "should re-render 'show'" do
          do_put
          response.should render_template('show')
        end
      end
    end
  end
end
