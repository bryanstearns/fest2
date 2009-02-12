module PrawnHelper
  class Layout
    ANDROID_FONT_DIR = "/usr/share/fonts/android"

    attr_reader :pdf, :styles

    @@heights = {}

    def initialize(pdf, options={})
      @font_size = 8 
      @pdf = pdf

      options.each {|k,v| instance_variable_set("@#{k}".to_sym, v)}

      pdf.font_families.update(
        "Droid" => {:normal => "#{ANDROID_FONT_DIR}/DroidSans.ttf",
                    :bold => "#{ANDROID_FONT_DIR}/DroidSans-Bold.ttf"})
      @styles = {
        :plain => ["Droid", {:style => :normal, :size => @font_size}],
        :bold => ["Droid", {:style => :bold, :size => @font_size}],
        :gray => ["Droid", {:style => :normal, :size => @font_size}],
        :small => ["Droid", {:style => :normal, :size => @font_size * 0.85}],
        :h1 => ["Droid", {:style => :bold, :size => @font_size * 1.3}],
        :h2 => ["Droid", {:style => :bold, :size => @font_size * 1.1}],
      }
      if @debug
        pdf.stroke_color= "00ffff"
        pdf.stroke_bounds
        pdf.stroke_color= "000000"
      end
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
      with_color(color) { pdf.stroke_horizontal_rule }
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
end
