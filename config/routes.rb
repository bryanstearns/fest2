ActionController::Routing::Routes.draw do |map|
  map.resources :announcements

  [[:festivals, :films, :screenings],
   [:conferences, :presentations, :slots]].each do |festz, filmz, screeningz|
    map.resources festz, :controller => 'festivals', :member => { 
      :pick_screening => :post, 
      :reset_rankings => :post,
      :reset_screenings => :post, 
    } do |festival|
      festival.resources filmz, :controller => 'films'
      festival.resources :venues
      festival.resource :settings, :controller => 'subscriptions', 
        :only => [:show, :update]
    end
    map.resources filmz, :controller => 'films', :collection => {
      :amazon => :get,
      :amazon_lookup => :post,
    }, :member => {
      :dvd => :get,
      :amazon_confirm => :post,
    } do |film|
      film.resources screeningz, :controller => 'screenings'
      film.resources :picks
    end
  end

  # The welcome controller provides a few site-global static-like pages
  map.with_options :controller => 'welcome' do |m|
    m.home '', :action => 'index'
    m.about '/about', :action => "about"
    m.community '/community', :action => "community" # for now...
    m.faq '/faq', :action => "faq"
    m.dvds '/dvds', :action => "dvds"
    m.oops '/oops', :action => "oops"
  end

  # Questions does feedback editing, but we also alias /feedback to its 'new'
  map.resources :questions
  map.feedback '/feedback', :controller => 'questions', :action => 'new'

  # Restful_Authentication
  map.resources :users
  map.resource :session, :controller => 'session'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'session', :action => 'new'
  map.logout '/logout', :controller => 'session', :action => 'destroy'
  map.send_password_reset '/send_password_reset', :controller => 'users', :action => 'send_password_reset', :method => :post
  map.reset_password '/users/:id/reset_password/:secret', :controller => 'users', :action => 'reset_password', :method => :post

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # BJS: OK.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
