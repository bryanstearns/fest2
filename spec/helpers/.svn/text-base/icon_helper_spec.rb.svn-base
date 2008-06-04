require File.dirname(__FILE__) + '/../spec_helper'

describe IconHelper do
  it "should include the IconHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(IconHelper)
  end
  
  it "should return the image tag, with title, for a known country" do
    tag = flag_icon_tag "us"
    tag.should match(%r{src="/images/fam3flags/us\.png})
    tag.should match(/title="United States"/)
    tag.should match(/alt="United States flag"/)
  end
  
  it "should return two tags for two countries" do
    tags = flag_icon_tag "us me"
    tags.should match(%r{us\.png.*me\.png})
  end
  
  it "should return nothing for unknown countries" do
    tag = flag_icon_tag "xx"
    tag.should == ''
  end
  
  it "should return nothing for nil or blank countries" do
    tag = flag_icon_tag ""
    tag.should == ''
    tag = flag_icon_tag nil
    tag.should == ''
  end
  
  it "should return a simple icon tag correctly" do
    tag = icon_tag :new
    tag.should match(%r{src="/images/fam3silk/new.png})
    tag.should match(/title="new"/)
    tag.should match(/alt="new"/)
  end
  
  it "should raise if an icon doesn't exist" do
    lambda { icon_tag :bogus }.should raise_error(IconHelper::MissingIcon)
  end
end
