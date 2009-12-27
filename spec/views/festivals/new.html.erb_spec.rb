require File.dirname(__FILE__) + '/../../spec_helper'

describe "/festivals/new.html.erb" do
  include FestivalsHelper
  
  before do
    @festival = mock_model(Festival)
    fields = []
    [:name, :location, :url, :film_url_format, :slug].each \
      { |f| @festival.stub!(f).and_return("MyString"); fields << f }
    [:starts, :ends].each \
      { |f| @festival.stub!(f).and_return(Date.today) }
#    [:public, :scheduled].each \
#      { |f| @festival.stub!(f).and_return(true); fields << f }    
    @festival_fields = fields    
    @festival.stub!(:films).and_return([])
    @festival.stub!(:revised_at).and_return(DateTime.now)    
    @festival.stub!(:new_record?).and_return(true)    
    assigns[:festival] = @festival
  end

  it "should render new form" do
    render "/festivals/new.html.erb"
    response.should have_tag("form[action=?][method=post]", festivals_path) do
      @festival_fields.each do |f|
        with_tag("input#festival_#{f}[name=?]", "festival[#{f}]")
      end
    end
  end
end


