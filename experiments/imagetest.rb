
RAILS_ENV = 'development'

require 'config/environment'
require 'ruby-debug'
require 'festivals_helper'
require 'application_helper'
require 'activesupport'
require 'benchmark'

include FestivalsHelper

ActiveRecord::Base.establish_connection

fest = Festival.find(1, :include => [:films, :venues, :screenings])
day_list = []
canvas_list = []
Benchmark.bm do |bm|
  bm.report { day_list << days(fest)[0] }
  bm.report { canvas_list << day_list[0].make_background(400) }
end
# canvas_list[0].display()
