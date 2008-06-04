require File.dirname(__FILE__) + '/../spec_helper'

describe VenuesController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:controller => "festivals", :action => "index" },
      :get, "/festivals" ],
    [ {:controller => 'festivals', :action => 'new' },
      :get, "/festivals/new" ],
    [ {:controller => 'festivals', :action => 'create' },
      :post, "/festivals" ],
    [ {:controller => 'festivals', :action => 'show', :id => "1" },
      :get, "/festivals/1" ],
    [ {:controller => 'festivals', :action => 'edit', :id => "1" },
      :get, "/festivals/1/edit" ],
    [ {:controller => 'festivals', :action => 'update', :id => "1" },
      :put, "/festivals/1" ],
    [ {:controller => 'festivals', :action => 'destroy', :id => "1" },
      :delete, "/festivals/1" ],
  ]
  
  check_routes routes
end