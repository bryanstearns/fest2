class Admin::ScreeningsController < ApplicationController
  active_scaffold :screening do |config|
    config.columns = [
      :festival, :film, :starts, :ends
    ]
    config.list.sorting = [{:festival => :asc}, {:film => :asc},
                           {:starts => :asc}]
    config.subform.columns = [ :film, :starts, :ends ]
  end
end
