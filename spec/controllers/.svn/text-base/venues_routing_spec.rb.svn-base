require File.dirname(__FILE__) + '/../spec_helper'

describe VenuesController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:festival_id => "1", :controller => "venues", :action => "index" },
      :get, "/festivals/1/venues" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'new' },
      :get, "/festivals/1/venues/new" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'create' },
      :post, "/festivals/1/venues" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'show', :id => "1" },
      :get, "/festivals/1/venues/1" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'edit', :id => "1" },
      :get, "/festivals/1/venues/1/edit" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'update', :id => "1" },
      :put, "/festivals/1/venues/1" ],
    [ {:festival_id => "1", :controller => 'venues', :action => 'destroy', :id => "1" },
      :delete, "/festivals/1/venues/1" ],
  ]
  
  check_routes routes
end