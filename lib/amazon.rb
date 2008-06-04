class Amazon
  def self.lookup(name, dump=false)
    xml = Net::HTTP.get(URI.parse(self.info_url(name)))
    puts xml if dump
    doc = REXML::Document.new(xml)
    data = []
    doc.elements.each("ItemSearchResponse/Items/Item") do |e|
      if %w{New Used Collectible Refurbished}.any? {|s| (e.elements["OfferSummary/Total#{s}"].text.to_i rescue 0) > 0 }
        title = CGI::unescape(e.elements["ItemAttributes/Title"].text)
        director = CGI::unescape(e.elements["ItemAttributes/Director"].text) rescue nil
        asin = CGI::unescape(e.elements["ASIN"].text)
        url = CGI::unescape(e.elements["DetailPageURL"].text)
        puts "\"#{name}\" --> \"#{title}\", #{url}"
        info = { :title => title, :director => director, :asin => asin, :url => url }
        imageElement = e.elements["SmallImage/URL"]
        info.update(:image => imageElement.text,
                    :height => e.elements["SmallImage/Height"].text.to_i,
                    :width => e.elements["SmallImage/Width"].text.to_i) \
          if imageElement
        data << info
      end
    end
    data.empty? ? nil : data
  end
  
  def self.info_url(name)
    "http://ecs.amazonaws.com/onca/xml?Service=AWSECommerceService&Version=2005-03-23&Operation=ItemSearch&SubscriptionId=0525E2PQ81DD7ZTWTK82&SearchIndex=DVD&ResponseGroup=OfferSummary,Small,Images&Title=" \
      + CGI::escape(name)
  end
end
