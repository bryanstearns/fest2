presenter = PrawnHelper::AllListSchedule.new(pdf, @festival, \
  logged_in? && current_user, @picks, :orientation => :landscape)
presenter.draw

# vim: set filetype=ruby :

