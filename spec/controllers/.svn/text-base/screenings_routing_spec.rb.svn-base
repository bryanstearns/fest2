require File.dirname(__FILE__) + '/../spec_helper'

describe ScreeningsController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:film_id => "1", :controller => "screenings", :action => "index" },
      :get, "/films/1/screenings" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'new' },
      :get, "/films/1/screenings/new" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'create' },
      :post, "/films/1/screenings" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'show', :id => "1" },
      :get, "/films/1/screenings/1" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'edit', :id => "1" },
      :get, "/films/1/screenings/1/edit" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'update', :id => "1" },
      :put, "/films/1/screenings/1" ],
    [ {:film_id => "1", :controller => 'screenings', :action => 'destroy', :id => "1" },
      :delete, "/films/1/screenings/1" ],
  ]
  
  check_routes routes
end