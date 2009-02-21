
module PrawnHelper
  class Presenter
    include FestivalsHelper
    attr_accessor :pdf, :festival, :user, :picks, :orientation, 
      :conference_mode
    attr_accessor :header_height, :footer_height, :column_count,
      :column_gutter, :column_width, :column_height, :column_index, :y

    ANDROID_FONT_DIR = "/usr/share/fonts/android"

    attr_reader :pdf, :styles

    @@heights = {}

    def initialize(pdf, festival, user, picks, options={})
      @pdf = pdf
      @festival = festival
      @user = user
      @picks = picks
      @orientation = options[:orientation] || :landscape
      @conference_mode = options[:conference_mode] || false

      options.each {|k,v| instance_variable_set("@#{k}".to_sym, v)}

      @font_size = 8

      pdf.font_families.update(
        "Droid" => {:normal => "#{ANDROID_FONT_DIR}/DroidSans.ttf",
                    :bold => "#{ANDROID_FONT_DIR}/DroidSans-Bold.ttf"})
      @styles = {
        :plain => ["Droid", {:style => :normal, :size => @font_size}],
        :bold => ["Droid", {:style => :bold, :size => @font_size}],
        :gray => ["Droid", {:style => :normal, :size => @font_size}],
        :small => ["Droid", {:style => :normal, :size => @font_size * 0.85}],
        :smallbold => ["Droid", {:style => :bold, :size => @font_size * 0.85}],
        :h1 => ["Droid", {:style => :bold, :size => @font_size * 1.3}],
        :h2 => ["Droid", {:style => :bold, :size => @font_size * 1.1}],
        :h3 => ["Droid", {:style => :bold, :size => @font_size * 1.0}],
      }

      start_page
      setup
    end

    def setup
      @header_height = 15
      @footer_height = 15
      @column_count = (orientation == :landscape) ? 4 : 3
      @column_gutter = 4 
      @column_width = (pdf.margin_box.width - \
                      (column_gutter * (column_count - 1))) / column_count
      @column_height = pdf.margin_box.height - (header_height + footer_height)

      @small_adj = font(:plain).ascender - font(:small).ascender

      @column_index = -1
      next_column(:initial)
    end

    def draw
      draw_header
      draw_footer
      draw_content
    end

    def start_page
      @pdf.start_new_page(:layout => @orientation)
      with_color("00ffff") { pdf.stroke_bounds } if @debug
    end

    def with_color(color)
      old_fill_color = pdf.fill_color
      old_stroke_color = pdf.stroke_color
      if color
        pdf.fill_color = pdf.stroke_color = color
      end
      yield if block_given?
      pdf.stroke_color = old_stroke_color
      pdf.fill_color = old_fill_color
    end

    def font(style, color=nil)
      f = pdf.font(*styles[style]) if style
      if block_given?
        with_color(color) do
          yield
        end
      else
        f
      end
    end

    def font_height(style)
      @@heights[style] ||= font(style).height
    end

    def hr(color)
      with_color(color) do
        pdf.stroke_horizontal_rule
      end
    end

    def text(msg, options={})
      font(options[:style]) do
        x = options.delete(:x) || 0
        y = options.delete(:y) || pdf.y
        width = options.delete(:width) || (pdf.bounds.right - x)
        height = options.delete(:height) || pdf.font.height
        pdf.text_box msg, options.merge(:overflow => :ellipses,
          :at => [x, y + pdf.font.ascender], 
          :width => width, :height => height)
      end
    end
  end

  class AllListSchedule < Presenter
    attr_accessor :day_name_width, :day_time_width

    def setup
      super
      @day_name_width = column_width * 0.56
      @day_time_width = column_width - @day_name_width
      @show_press = user && user.subscription_for(festival, :create => true).show_press

      @film_id_to_screening_id = {}
      @film_id_to_priority = {}
      picks.each do |p| 
        @film_id_to_screening_id[p.film_id] = p.screening_id if p.screening_id
        @film_id_to_priority[p.film_id] = p.priority if p.priority
      end
    end

    def draw_header
      pdf.header pdf.margin_box.top_left do
        font(:h1) do
          prefix = "#{user.login} is a " if user
          pdf.text "#{prefix}festival fanatic!", :align => :left 
          pdf.move_up pdf.font.height
          pdf.text festival.name, :align => :right
        end
        hr("aaaaaa")
      end
    end

    def draw_footer
      fest_date = (festival.revised_at || festival.modified_at).to_s(:full)
      #user_date = picks.max(&:updated_at).to_s(:full)

      pdf.footer [pdf.margin_box.left, 
                  pdf.margin_box.bottom + footer_height] do
        hr("aaaaaa")
        font(:small) do
          pdf.move_down(2)
          pdf.text "http://festivalfanatic.com/", :align => :left
          pdf.move_up(pdf.font.height)
          pdf.text "festival as of #{fest_date}", # choices as of #{user_date}"
            :align => :right
        end
      end
    end

    def next_column(reason)
      Rails.logger.info "next column: #{reason}"
      @column_index += 1
      if @column_index == @column_count
        start_page
        @column_index = 0
      end
      @y = footer_height + column_height
      @left = column_index * (column_width + column_gutter)
      @right = @left + column_width
    end

    def draw_content
      days(festival, conference_mode, @show_press).each do |day|
        draw_day(day)
      end
      @y -= 3
      draw_films
    end

    def room?(needed)
      result = needed <= (y - footer_height)
      Rails.logger.info "Room for #{needed} vs #{y - footer_height} -- #{result}"
      result
    end

    def draw_day(day)
      return if day.screenings.empty?
      screenings = day.screenings.clone
      min_height = (font_height(:plain) * [2, screenings.size].min) +
                   font_height(:h2) + 2
      next_column(:widow) unless room? min_height
      continued = ""
      loop do
        height = (font_height(:plain) * screenings.size) +
                  font_height(:h2) + 2

        #daybox = pdf.lazy_bounding_box(
          #[column_index * (column_width + column_gutter), y],
          #:width => column_width, :height => height) do
        font(:h3) do 
          pdf.text_box day.date.strftime("%A, %B #{day.date.day}#{continued}"),
            :at => [@left, @y],
            :width => column_width, :height => pdf.font.height
          @y -= pdf.font.height + 1
        end
        with_color("aaaaaa") do 
          pdf.horizontal_line(@left, @left + column_width, :at => @y)
          @y -= 2
        end
        (0...screenings.size).each do |index|
          Rails.logger.info "Starting screening #{index}"
          unless room?(font_height(:plain))
            next_column(:indiv)
            break
          end
          Rails.logger.info "Continuing screening #{index} (#{screenings.size} remaining)"

          s = screenings.shift
          font(:small) do
            pdf.text_box "#{s.times} #{s.venue.abbrev}",
              :at => [@left, @y - @small_adj],
              :width => day_time_width, :height => pdf.font.height
          end

          font(*name_style(s)) do
            pdf.text_box s.film.name,
              :at => [@left + day_time_width, @y], :overflow => :ellipses,
              :width => day_name_width, :height => pdf.font.height
            @y -= pdf.font.height
          end
        end
        @y -= 2
        return if screenings.empty?
        continued = " (cont'd)"
      end # cont'd loop
    end # draw_day

    def name_style(screening)
      case @film_id_to_screening_id[screening.film_id]
        when screening.id
          [:bold]
        #when nil
          #[:plain, "888888"]
        else
          [:plain]
      end
    end

    def time_style(screening)
      case @film_id_to_screening_id[screening.film_id]
        when screening.id
          [:smallbold]
        else
          [:small]
      end
    end

    def draw_films
      return if festival.films.empty?
      films = festival.films.clone.sort_by(&:sort_name)
      indent = 5
      image_width = 40

      # Require enough room for the title and first film
      film = films[0]
      min_height = (font_height(:h3) + 4 + \
                    font_height(:plain) + \
                    ((film.screenings.size + 1) * font_height(:small)))
      next_column(:widow) unless room? min_height
      continued = ""
      font(:h3) do 
        pdf.text_box "Film Index#{continued}",
          :at => [@left, @y],
          :width => column_width, :height => pdf.font.height
        @y -= pdf.font.height + 1
      end
      with_color("aaaaaa") do 
        pdf.horizontal_line(@left, @left + column_width, :at => @y)
        @y -= 2
      end
      loop do
        (0...films.size).each do |index|
          return if films.empty?
          film = films[0]

          Rails.logger.info "Starting film #{index}"
          unless room?(font_height(:plain) + font_height(:small) + \
                       (film.screenings.size * font_height(:small)))
            next_column(:indiv)
            break
          end
          Rails.logger.info "Continuing film #{index} (#{films.size} remaining)"

          font(:bold) do
            pdf.text_box film.name,
              :at => [@left, @y], :overflow => :ellipses,
              :width => column_width, :height => pdf.font.height
            @y -= pdf.font.height
          end

          font(:small) do
            priority = @film_id_to_priority[film.id]
            if priority
              pdf.image "public/images/priority/p#{priority}.png",
                :at => [@left, @y], :height => pdf.font.height * 0.8
              iw = image_width
            else
              iw = 0
            end

            countries = film.country_names
            countries = ", #{countries}" unless countries.blank?
            pdf.text_box "#{film.duration / 1.minute} minutes, #{countries}",
              :at => [@left + iw, @y],
              :width => column_width - iw, :height => pdf.font.height
            @y -= pdf.font.height
          end

          film.screenings.with_press(@show_press).sort_by(&:starts).each do |s|
            font(*time_style(s)) do
              pdf.text_box "#{s.starts.to_s(:short_date)} #{s.starts.to_time_label} #{s.venue.abbrev} #{' (press)' if s.press}",
                :at => [@left + indent, @y],
                :width => column_width - indent, :height => pdf.font.height
              @y -= pdf.font.height
            end
          end
          @y -= 3

          films.shift
        end
        return if films.empty?
        continued = " (cont'd)"
      end # cont'd loop
    end # draw_films
  end
end

class Prawn::Document
  # Shorten the inspection of pdf-referencing objects
  def inspect
    "<Prawn::Document #{object_id}>"
  end
end

# vim: set filetype=ruby :
