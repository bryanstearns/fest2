class ActivityController < ApplicationController
  before_filter :require_admin

  def index
    @activity = Activity.all(:order => "created_at desc")
  end
end
