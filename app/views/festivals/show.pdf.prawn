presenter = PrawnHelper::AllListSchedule.new(pdf, @festival, \
  @displaying_user, @picks, :orientation => :landscape)
presenter.draw

# vim: set filetype=ruby :

