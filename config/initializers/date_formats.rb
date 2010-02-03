
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :day_month_date => lambda {|d| d.strftime("%A %B #{d.day}") },
  :full => lambda {|d| d.strftime("%l:%M %p, %B #{d.day.to_i}, %Y") },
  :csv => lambda {|d| d.strftime("%m/%d/%y %l:%M %p") },
  :short_date => lambda {|d| "#{Date::ABBR_DAYNAMES[d.wday]}, #{d.month}/#{d.day}"}
)
