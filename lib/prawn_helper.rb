module PrawnHelper
  class Layout
    ANDROID_FONT_DIR = "/usr/share/fonts/android"

    delegate :text, :to => :pdf

    attr_reader :pdf, :styles
    def initialize(pdf, options={})
      @runs = []
      @font_size = 11
      @pdf = pdf
      options.each {|k,v| instance_variable_set("@#{k}".to_sym, v)}

      pdf.font_families.update(
        "Droid" => {:normal => "#{ANDROID_FONT_DIR}/DroidSans.ttf",
                    :bold => "#{ANDROID_FONT_DIR}/DroidSans-Bold.ttf"})
      @styles = {
        :plain => ["Droid", {:style => :normal, :size => @font_size}],
        :small => ["Droid", {:style => :normal, :size => @font_size * 0.85}],
        :h1 => ["Droid", {:style => :bold, :size => @font_size * 1.3}],
        :h2 => ["Droid", {:style => :bold, :size => @font_size * 1.1}],
      }
      @heights = {}

      pdf.stroke_bounds if @debug
    end

    def <<(run_params)
      @runs << Run.new(self, *run_params)
    end

    def measure(pairs)
      widths = []
      heights = []
      chunks = pairs.map do |style, text|
        f = pdf.font(*styles[style])
        widths << width = f.width(text)
        heights << height = (@heights[style] ||= f.height)
        [style, text, width]
      end
      return widths.sum, heights.max, chunks
    end

    def draw(pairs)
      pairs.each do |style, text, width|
        pdf.font(*styles[style])
        pdf.text(text)
      end
    end

    def font(style)
      f = pdf.font(*styles[style])
      if block_given?
        yield
      else
        f
      end
    end

  end

  class Run
    def initialize(layout, style, text)
      @layout = layout
      @style = style
      @text = text
      measure
    end

    def measure
      f = @layout.font(style)
      @width = f.width(text)
      @height = (@@heights[style] ||= f.height)
        [style, text, width]
  end
end
