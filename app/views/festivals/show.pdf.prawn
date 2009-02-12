
layout = :landscape
pdf.start_new_page(:layout => layout)
ph = PrawnHelper::Layout.new(pdf, :debug => false)

header_height = 18
footer_height = 15
column_count = layout ? 5 : 3
column_gutter = 4 
column_width = (pdf.margin_box.width - \
                (column_gutter * (column_count - 1))) / column_count
column_height = pdf.margin_box.height - (header_height + footer_height)

time_width = column_width * 0.35
name_width = column_width - time_width

pdf.header pdf.margin_box.top_left do
  if logged_in?
    ph.font(:h1) do
      pdf.text "#{current_user.login} is a festival fanatic!", :align => :left 
      pdf.move_up pdf.font.height
    end
  end
  ph.font(:h1) { pdf.text @festival.name, :align => :right }
  ph.hr("aaaaaa")
end

fest_date = (@festival.revised_at || @festival.modified_at)\
            .to_s(:full)
#user_date = @picks.max(&:updated_at).to_s(:full)

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + footer_height] do
  ph.hr("aaaaaa")
  ph.font(:small) do
    pdf.move_down(2)
    pdf.text "http://festivalfanatic.com/", :align => :left
    pdf.move_up(pdf.font.height)
    pdf.text "festival as of #{fest_date}", #, choices as of #{user_date}",
      :align => :right
  end
end

#picked_screenings = {}
film_id_to_screening = {}
@picks.each do |p| 
  #picked_screenings[p.screening_id] = true
  film_id_to_screening[p.film_id] = p.screening_id if p.screening_id
end

small_adj = ph.font(:plain).ascender - ph.font(:small).ascender

column_index = 0
y = footer_height + column_height

days(@festival, conference_mode, @show_press).each do |day|
  min_height = (ph.font_height(:plain) * [2, day.screenings.size].min) +
               ph.font_height(:h2) + 2
  if y <= min_height
    Rails.logger.info "next column!"
    y = footer_height + column_height
    column_index += 1
  end
  screenings = day.screenings.clone
  ["", " (cont'd)"].each do |continued|
    unless screenings.empty?
      height = (ph.font_height(:plain) * screenings.size) +
                ph.font_height(:h2) + 2
      daybox = pdf.lazy_bounding_box(
          [column_index * (column_width + column_gutter), y],
          :width => column_width, :height => height) do
        ph.font(:h2) do 
          pdf.text_box day.date.strftime("%A, %B #{day.date.day}#{continued}"),
            :at => [0, pdf.bounds.top],
            :width => column_width, :height => pdf.font.height
        end
        pdf.move_down(1)
        ph.hr("aaaaaa")
        pdf.move_down(1)

        screening_top = pdf.bounds.top - (ph.font_height(:h2) + 2)
        (0..screenings.size).each do |index|
          screening_y = screening_top - (ph.font_height(:plain) * index)
          break if screening_y < ph.font_height(:plain)

          s = screenings.shift
          ph.font(:small) do
            pdf.text_box "#{s.starts.to_time_label} #{s.venue.abbrev}",
              :at => [0, screening_y - small_adj],
              :width => time_width, :height => pdf.font.height
          end

          name_style = case film_id_to_screening[s.film_id]
            when nil
              [:plain]
            when s.id
              [:bold]
            else
              [:plain, "888888"]
          end
          ph.font(*name_style) do
            pdf.text_box s.film.name,
              :at => [time_width, screening_y],
              :width => name_width, :height => pdf.font.height
          end
        end
        pdf.move_down(2)
      end
      daybox.draw
      y -= height
    end
  end
end

# vim: set filetype=ruby :
