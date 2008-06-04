require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionsController do
  include AdminUserSpecHelper
  
  describe "handling GET /questions" do

    before(:each) do
      login_as admin_user
      @question = mock_model(Question)
      Question.stub!(:find).and_return([@question])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all questions" do
      Question.should_receive(:find).with(:all).and_return([@question])
      do_get
    end
  
    it "should assign the found questions for the view" do
      do_get
      assigns[:questions].should == [@question]
    end
  end

  describe "handling GET /questions.xml" do

    before(:each) do
      login_as admin_user
      @question = mock_model(Question, :to_xml => "XML")
      Question.stub!(:find).and_return(@question)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all questions" do
      Question.should_receive(:find).with(:all).and_return([@question])
      do_get
    end
  
    it "should render the found questions as xml" do
      @question.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /questions/1" do

    before(:each) do
      login_as admin_user
      @question = mock_model(Question)
      Question.stub!(:find).and_return(@question)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the question requested" do
      Question.should_receive(:find).with("1").and_return(@question)
      do_get
    end
  
    it "should assign the found question for the view" do
      do_get
      assigns[:question].should equal(@question)
    end
  end

  describe "handling GET /questions/1.xml" do

    before(:each) do
      login_as admin_user
      @question = mock_model(Question, :to_xml => "XML")
      Question.stub!(:find).and_return(@question)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the question requested" do
      Question.should_receive(:find).with("1").and_return(@question)
      do_get
    end
  
    it "should render the found question as xml" do
      @question.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /questions/new" do

    before(:each) do
      @question = mock_model(Question)
      Question.stub!(:new).and_return(@question)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new question" do
      Question.should_receive(:new).and_return(@question)
      do_get
    end
  
    it "should not save the new question" do
      @question.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new question for the view" do
      do_get
      assigns[:question].should equal(@question)
    end
  end

  describe "handling POST /questions" do
    before(:each) do
      @question = mock_model(Question, :to_param => "1")
      @question.stub!(:email).and_return("bogus@example.com")
      @question.stub!(:question).and_return("wtf?")
      Question.stub!(:new).and_return(@question)

      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end
    
    describe "with successful save" do
  
      def do_post
        @question.should_receive(:save).and_return(true)
        post :create, :question => {}
      end
  
      it "should create a new question" do
        Question.should_receive(:new).with({}).and_return(@question)
        do_post
      end

      it "should render 'create'" do
        do_post
        response.should render_template('create')
      end
      
      it "should send an admin email" do
        do_post
        ActionMailer::Base.deliveries.size.should == 1
        response.should send_email do
          with_tag("blockquote", "wtf?")
        end
      end
    end
    
    describe "with failed save" do

      def do_post
        @question.should_receive(:save).and_return(false)
        post :create, :question => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
      it "should not send an admin email" do
        do_post
        ActionMailer::Base.deliveries.size.should == 0
      end
    end
  end

  describe "handling DELETE /questions/1" do

    before(:each) do
      login_as admin_user
      @question = mock_model(Question, :destroy => true)
      Question.stub!(:find).and_return(@question)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the question requested" do
      Question.should_receive(:find).with("1").and_return(@question)
      do_delete
    end
  
    it "should call destroy on the found question" do
      @question.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the questions list" do
      do_delete
      response.should redirect_to(feedback_url)
    end
  end
end