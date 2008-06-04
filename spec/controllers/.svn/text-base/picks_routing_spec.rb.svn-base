require File.dirname(__FILE__) + '/../spec_helper'

describe PicksController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:film_id => "1", :controller => 'screenings', :action => 'create' },
      :post, "/films/1/screenings" ],
  ]
  
  check_routes routes
end