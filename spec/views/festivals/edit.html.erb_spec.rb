require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/edit.html.erb" do
  include FestivalsHelper
  
  before do
    @festival = mock_model(Festival)
    fields = []
    [:name, :location, :url, :film_url_format, :slug].each \
      { |f| @festival.stub!(f).and_return("MyString"); fields << f }
    [:starts, :ends].each \
      { |f| @festival.stub!(f).and_return(Date.today) }
    [:public, :scheduled].each \
      { |f| @festival.stub!(f).and_return(true); fields << f }    
    @festival_fields = fields    
    @festival.stub!(:films).and_return([])
    @festival.stub!(:venues).and_return([])
    @festival.stub!(:revised_at).and_return(DateTime.now)
    assigns[:festival] = @festival
    
    @controller.template.stub!(:button_to_remote).and_return('')
  end
  
  it "should render edit form" do

    render "/festivals/edit.html.erb"
	
    response.should have_tag("form[action=#{festival_path(@festival)}][method=post]") do
      @festival_fields.each do |f|
        with_tag("input#festival_#{f}[name=?]", "festival[#{f}]")
      end
    end
  end
end


