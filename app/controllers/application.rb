# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class NonAjaxEditsNotSupported < Exception  
end

class TooManyVenueConflicts < Exception
end

class AutoSchedulingError < Exception
end

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '628adf0a9fb7cd0ff7dabfe3c991d940'
  
  # Use our standard layout for all non-AJAX/non-RSS-feed requests
  layout proc {|c| (c.request.xhr? || c.request.format.to_s.include?("xml")) ? false : "standard-layout" }
  
  # Tell me when I'm hosed
  include ExceptionNotifiable

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  # What mode are we in?
  include ConferenceVsFestival
  
  # Do authentication stuff
  include AuthenticatedSystem
  before_filter :conference_versus_festival,
                :login_from_cookie,
                :admin_check
  
  def admin_check
    # Is the user required to be an admin for this page?
    admin_required = self.class.controller_path.starts_with?("admin/")
    render(:file => "#{RAILS_ROOT}/public/404.html", :status => 404) and return \
      if admin_required and not (current_user.admin rescue false)
  end

  def require_admin_subscription
    # Called by privileged festival-related operations: raises unless the 
    # user has admin access to this festival.
    redirect_to login_url and return unless logged_in?
    # logger.info ":id = #{params.inspect}, current_user.admin = #{current_user.admin}, fest_admin = #{current_user.subscriptions.find_by_festival_id(params[:id]).admin rescue "rescued false"}"
    raise(ActiveRecord::RecordNotFound) \
      unless current_user.admin or (current_user.subscriptions.find_by_festival_id(params[_[:festival_id]] || params[:id]).admin rescue false)
    true
  end

  def require_admin
    # Like above, but doesn't check for festival.
    redirect_to login_url and return unless logged_in?
    raise(ActiveRecord::RecordNotFound) \
      unless current_user.admin
    true    
  end

  def check_festival_access
    # Called by unprivileged operations: does nothing on public festivals, but
    # raises if the festival isn't public and the user doesn't have access.    
    raise(ActiveRecord::RecordNotFound) \
      unless @festival and (@festival.is_conference == conference_mode) \
        and (@festival.public or \
             (logged_in? and (current_user.admin or \
                              (current_user.subscriptions.find_by_festival_id(@festival.id).admin \
                               rescue false))))
  end

  # Give access to some view helpers from within controllers;
  # use like: view_helper.pluralize(count, "thing")
  # http://snippets.dzone.com/posts/show/1799
  def view_helper
    ViewHelper.instance
  end
  class ViewHelper
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
  end

  def find_scope(unlimited_if_admin=true)
    if (unlimited_if_admin and (current_user.admin rescue false))
      :unlimited
    else
      _[:festivals].to_sym
    end
  end

  # I'd like to use this before_filter, but it doesn't work with rspec :-(
#  def disallow_html_edits
#    puts "Checking request format: '#{request.format.inspect}'"
#    raise(NonAjaxEditsNotSupported) if request.format == Mime::HTML
#  end
  
  def rescue_action_in_public(exception)
    # We override ExceptionNotifiable's version of this, to force redirection
    # in all cases to our oops page (after sending mail just the way it does,
    # if the error isn't 404-equivalent)
    four_oh_four_like = self.class.exceptions_to_treat_as_404.any? do 
      |e| e === exception
    end
    # Google's crawler does GETs - don't send mail for those.
    four_oh_four_like ||= (exception.is_a?(ActionController::MethodNotAllowed) \
      && (ENV["HTTP_FROM"] == "googlebot(at)googlebot.com"))

    unless four_oh_four_like
      deliverer = self.class.exception_data
      data = case deliverer
        when nil then {}
        when Symbol then send(deliverer)
        when Proc then deliverer.call(self)
      end

      ExceptionNotifier.deliver_exception_notification(exception, self,
        request, data)
    end
    
    if request.xhr?
      render :update do |page|
        page.redirect_to oops_url
      end
    else
      redirect_to oops_url
    end
  end

  # Override local_request? to always return false, per
  # http://www.semergence.com/2006/12/01/when-local-is-remote-in-rails-and-other-tales-of-eccentric-error-enforcement/
  # (The code that calls this does "consider_all_requests_local || local_request?"
  # when deciding whether to show detailed vs generic error pages; this means 
  # we'll always get full error messages except in production, 
  # where consider_all_requests_local is false.
  def local_request?
    false
  end
end
