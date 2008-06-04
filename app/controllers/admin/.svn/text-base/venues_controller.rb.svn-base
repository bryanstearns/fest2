class Admin::VenuesController < ApplicationController
  active_scaffold :venue do |config|
    config.columns = [:festival, :name, :abbrev]
    config.list.sorting = [{:festival => :asc}, {:name => :asc}]    
    config.columns[:festival].form_ui = :select
    config.subform.columns = [:name, :abbrev]
  end
end
