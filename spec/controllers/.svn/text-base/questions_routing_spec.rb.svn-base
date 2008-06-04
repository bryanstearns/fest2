require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionsController do
  include RoutesHelper
  routes = [
    # params, method, route
    [ {:controller => "questions", :action => "index" },
      :get, "/questions" ],
    [ {:controller => 'questions', :action => 'new' },
      :get, "/questions/new" ],
    [ {:controller => 'questions', :action => 'create' },
      :post, "/questions" ],
    [ {:controller => 'questions', :action => 'show', :id => "1" },
      :get, "/questions/1" ],
    [ {:controller => 'questions', :action => 'edit', :id => "1" },
      :get, "/questions/1/edit" ],
    [ {:controller => 'questions', :action => 'update', :id => "1" },
      :put, "/questions/1" ],
    [ {:controller => 'questions', :action => 'destroy', :id => "1" },
      :delete, "/questions/1" ],
  ]
  
  check_routes routes
end