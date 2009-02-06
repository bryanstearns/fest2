class PrawnHelper
  ANDROID_FONT_DIR = "/usr/share/fonts/android"

  attr_reader :pdf, :s
  def initialize(pdf, options={})
    @font_size = 11
    @pdf = pdf
    options.each {|k,v| instance_variable_set("@#{k}".to_sym, v)}

    pdf.font_families.update(
      "Droid" => {:normal => "#{ANDROID_FONT_DIR}/DroidSans.ttf",
                  :bold => "#{ANDROID_FONT_DIR}/DroidSans-Bold.ttf"})
    @s = {
      :plain => ["Droid", {:style => :normal, :size => @font_size}],
      :small => ["Droid", {:style => :normal, :size => @font_size * 0.85}],
      :h1 => ["Droid", {:style => :bold, :size => @font_size * 1.3}],
      :h2 => ["Droid", {:style => :bold, :size => @font_size * 1.1}],
    }
    @heights = {}

    pdf.stroke_bounds if @debug
  end

  def measure(pairs)
    widths = []
    heights = []
    chunks = pairs.map do |style, text|
      f = pdf.font(*s[style])
      widths << width = f.width(text)
      heights << height = (@heights[style] ||= f.height)
      [style, text, width]
    end
    return widths.sum, heights.max, chunks
  end

  def draw(pairs)
    pairs.each do |style, text, width|
      pdf.font(*s[style])
      pdf.text(text)
    end
  end

  def font(style)
    pdf.font(*s[style]) do
      yield
    end
  end

  def text(msg, options={})
    pdf.text msg, options
  end
end

