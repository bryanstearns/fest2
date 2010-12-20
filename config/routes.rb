ActionController::Routing::Routes.draw do |map|
  map.resources :announcements
  map.news '/news', :controller => 'announcements', :action => 'index'

  map.resources :festivals, :controller => 'festivals', :member => { 
    :pick_screening => :post, 
    :reset_rankings => :post,
    :reset_screenings => :post, 
  } do |festival|
    festival.resources :films
    festival.resources :venues
    festival.resource :assistant, :controller => 'subscriptions', 
      :only => [:show, :update]
    festival.user '/:other_user_id/:key.:format', :controller => 'festivals', :action => 'show', :method => :get
  end
  map.resources :films, :controller => 'films' do |film|
    film.resources :screenings
    film.resources :picks
    film.resources :buzz
  end
  map.resources :buzz, :only => [:show, :edit, :update]

  # The welcome controller provides a few site-global static-like pages
  map.with_options :controller => 'welcome' do |m|
    m.home '/home', :action => 'index'
    m.about '/about', :action => "about"
    m.community '/community', :action => "community" # for now...
    m.faq '/faq', :action => "faq"
    m.oops '/oops', :action => "oops"
  end
  map.root :controller => 'welcome', :action => 'index'

  # Questions does feedback editing, but we also alias /feedback to its 'new'
  map.resources :questions
  map.feedback '/feedback', :controller => 'questions', :action => 'new'

  # Restful_Authentication
  map.resources :users
  map.resource :session, :controller => 'session'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'session', :action => 'new'
  map.logout '/logout', :controller => 'session', :action => 'destroy'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.send_password_reset '/send_password_reset', :controller => 'users', :action => 'send_password_reset', :method => :post
  map.reset_password '/users/:id/reset_password/:secret', :controller => 'users', :action => 'reset_password', :method => :post
end
