ph = PrawnHelper.new(pdf, :debug => true)

pdf.header pdf.margin_box.top_left do
  ph.font(:h1) { ph.text @festival.name, :align => :center }
  pdf.stroke_horizontal_rule
end

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
  pdf.stroke_horizontal_rule
  ph.font(:small) { ph.text "revised #{@festival.revised_at.to_s}", 
                      :align => :right }
end


column_count = 5
column_gutter = 10
column_width = (pdf.margin_box.width - \
                (column_gutter * (column_count - 1))) / column_count

days(@festival, conference_mode, @show_press).each do |day|
  pdf.text day.date.to_s
end

# vim: set filetype=ruby :
