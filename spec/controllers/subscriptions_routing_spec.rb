
require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionsController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'create' },
      :post, "/festivals/1/settings" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'new' },
      :get, "/festivals/1/settings/new" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'show' },
      :get, "/festivals/1/settings" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'edit' },
      :get, "/festivals/1/settings/edit" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'update' },
      :put, "/festivals/1/settings" ],
    [ {:festival_id => "1", :controller => 'subscriptions', :action => 'destroy' },
      :delete, "/festivals/1/settings" ],
  ]
  
  check_routes routes
end
