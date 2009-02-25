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
      festival.user '/:other_user_id/:key', :controller => 'festivals', :action => 'show', :method => :get
      festival.formatted_user '/:other_user_id/:key.:format', :controller => 'festivals', :action => 'show', :method => :get
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
end
