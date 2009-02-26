
require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionsController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'show' },
      :get, "/festivals/1/assistant" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'update' },
      :put, "/festivals/1/assistant" ],
  ]
  
  check_routes routes
end
