class RoundCornerContext  
  def initialize(options, concatter, &block)
    options.each_pair {|n,v| instance_variable_set("@#{n}".to_sym, v) }
    @concatter = concatter
    width = @width ? %Q{ style="width: #{@width}"} : ""
    @opening_only = !@tabs && !@sidebar
    @tabs_only = @tabs && !@sidebar
    @sidebar_only = @sidebar && !@tabs
    
    colspan = @sidebar ? %Q{ colspan="3"} : ""
    concat <<OPENING, "doit OPENING"
<table class="rounded" #{width}>
  <tr>
    <td class="tl"/>
    <td class="t"#{colspan}/>
    <td class="tr"/>    
  </tr>
  <tr>
    <td class="l"/>
    <td#{colspan}>
OPENING
    yield self
    finish_opening

    if @opening_only || @sidebar_done
      concat <<FINISH, "doit CLOSING"
  <tr>
    <td class="bl"/>
    <td class="b"></td>
    <td class="br"/>
  </tr>
</table>
FINISH
    end
  end
  
  def concat(msg, debug=nil)
    @concatter.call("\n<!-- #{debug} start -->\n") unless debug.nil?
    @concatter.call(msg)
    @concatter.call("\n<!-- #{debug} end -->\n") unless debug.nil?
  end
  
  def finish_opening
    unless @opening_finished
      tableclose = @sidebar_only ? <<TABLECLOSE : ""
  <tr>
    <td class="l"/>
    <td class="tabspacer" colspan="2"/>
    <td class="b"></td>
    <td class="br"/>
  </tr>
</table>
TABLECLOSE
      concat <<OPENINGFINISH, "doit OPENINGFINISH"
    </td>
    <td class="r"/>
  </tr>
#{tableclose}
OPENINGFINISH
      @opening_finished = true
    end
  end
  
  def tabs
    finish_opening
    spacer = @sidebar ? %Q{<td class="tabspacer" colspan="2">#{@sidebarcap || ""}</td>} : ""
    leftclass = @tabs_only ? "bl" : "l"
    concat <<PREFIX, "tabs PREFIX"
  <tr>
    <td class="#{leftclass}"/>#{spacer}
    <td class="b tabs">
PREFIX
    yield
    concat <<SUFFIX, "tabs SUFFIX"
    </td>
    <td class="br"/>
  </tr>
</table>
SUFFIX
  end
  
  def tab(label, options={}, html_options={})
    label = "<div class=\"label\">#{label}</div>"
    if @context.current_page?(options)
      classname = "active"
      link = label # don't make this tab a link
    else
      classname = "inactive"
      link = @context.link_to(label, options, html_options)
    end
    concat %Q{<div id="tab1" class="tab #{classname}">#{link}</div>}, "TAB"
  end

  def sidebar(&block)
    finish_opening
    concat <<PREFIX, "sidebar PREFIX"
<table class="rounded sidebar" style="width: 220px">  
  <tr>
    <td class="l"/>
    <td>
PREFIX
    yield
    concat <<SUFFIX, "sidebar SUFFIX"
    </td>
    <td class="r"/>
  </tr>
SUFFIX
    @sidebar_done = true
  end

end

module RoundCornersHelper
  def round_corners(options={}, &block)
    options.symbolize_keys!
    concat("<!-- round_corners start -->", block.binding)
    RoundCornerContext.new(options, lambda { |msg| concat(msg, block.binding) }, &block)
    concat("<!-- round_corners end -->\n\n\n", block.binding)
  end
end
