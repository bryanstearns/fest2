class Admin::FestivalsController < ApplicationController
  active_scaffold :festival do |config|
    config.columns = [ 
      :name, :location, :public, :scheduled, :starts, :ends, 
      :url, :film_url_format #, :venues, :films, :screenings
    ]
#    [:venues, :films, :screenings].each do |col|
#      config.columns[col].collapsed = true
#    end
    config.list.columns = [ 
      :id, :name, :location, :dates, :public, :scheduled 
    ]
    config.nested.add_link("Venues", [:venues])
    config.nested.add_link("Films", [:films])
    config.nested.add_link("Screenings", [:screenings])    
  end
end
