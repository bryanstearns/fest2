class Admin::FilmsController < ApplicationController
  active_scaffold :film do |config|
    config.columns = [
      :festival, :name, :duration, :description, :url_fragment
    ]
    config.list.sorting = [{:festival => :asc}, {:name => :asc}]
    config.subform.columns = [:name, :duration, :url_fragment ]
  end
end
