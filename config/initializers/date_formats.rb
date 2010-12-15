# Custom time and date formats

date_formats = {
  :month_date_year =>
    lambda {|d| d.strftime("%B #{d.day.ordinalize}, %Y") },
  :month_date =>
    lambda {|d| d.strftime("%B #{d.day.ordinalize}") },
  :day_month_date_year =>
    lambda {|d| d.strftime("%A, %B #{d.day.ordinalize}, %Y") },
  :day_month_date =>
    lambda {|d| d.strftime("%A, %B #{d.day.ordinalize}") },
  :mdy_numbers_slashed =>
    lambda {|d| d.strftime("#{d.month}/#{d.day}/%Y") },
  :js => "%Y-%m-%d", # for passing dates to javascript
  :short_date => lambda {|d| "#{Date::ABBR_DAYNAMES[d.wday]}, #{d.month}/#{d.day}"},
  :abbr_month_day_year => lambda {|d| d.strftime("%b. #{d.day.ordinalize}, %Y") }
}

time_formats = {
  :time_on_month_day_year =>
    lambda {|d| d.strftime("%l:%M%p on %B #{d.day.ordinalize}, %Y") },
  :mdy_numbers_slashed_with_time =>
    lambda {|d| d.strftime("#{d.month}/#{d.day}/%Y %l:%M %p") },
  :day_date_time_zone =>
    lambda {|d| "#{Date::ABBR_DAYNAMES[d.wday]} #{d.to_s}" },
  :full => lambda {|d| d.strftime("%l:%M%p, %B #{d.day.to_i}, %Y") },
  :csv => lambda {|d| d.strftime("%m/%d/%y %l:%M %p") }
}

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(date_formats)
Time::DATE_FORMATS.merge!(date_formats.merge(time_formats))

# Here are all the formatting options. You're welcome.
# %a - The abbreviated weekday name (``Sun'')
# %A - The  full  weekday  name (``Sunday'')
# %b - The abbreviated month name (``Jan'')
# %B - The  full  month  name (``January'')
# %c - The preferred local date and time representation
# %d - Day of the month (01..31)
# %e - Day of the month with leading space instead of 0 (UNDOCUMENTED)
# %H - Hour of the day, 24-hour clock (00..23)
# %I - Hour of the day, 12-hour clock (01..12)
# %j - Day of the year (001..366)
# %l - Hour of the day with leading space instead of 0 (UNDOCUMENTED)
# %m - Month of the year (01..12)
# %M - Minute of the hour (00..59)
# %p - Meridian indicator (``AM''  or  ``PM'')
# %S - Second of the minute (00..60)
# %U - Week  number  of the current year,
#         starting with the first Sunday as the first
#         day of the first week (00..53)
# %W - Week  number  of the current year,
#         starting with the first Monday as the first
#         day of the first week (00..53)
# %w - Day of the week (Sunday is 0, 0..6)
# %x - Preferred representation for the date alone, no time
# %X - Preferred representation for the time alone, no date
# %y - Year without a century (00..99)
# %Y - Year with century
# %Z - Time zone name
# %% - Literal ``%'' character
