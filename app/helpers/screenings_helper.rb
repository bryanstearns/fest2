module ScreeningsHelper
  def screening_label(screening, pick)
    text = ["#{screening.date_and_times}, <span>#{screening.venue.name}"]
    text << " (press)" if screening.press
    if pick && pick.screening_id == screening.id
      text << icon_tag(:tick)
    end
    text << "</span>"
    text.join('')
  end
end
