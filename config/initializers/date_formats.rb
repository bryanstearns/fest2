
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :day_month_date => lambda {|d| d.strftime("%A %B #{d.day}") },
  :full => lambda {|d| d.strftime("%l:%M %p, %B #{d.day.to_i}, %Y") }
)
