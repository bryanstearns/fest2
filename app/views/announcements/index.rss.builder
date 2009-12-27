xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "FestivalFanatic.com News"
    xml.description "What's new on http://festivalfanatic.com"
    xml.link announcements_url(:format => :rss)
    
    for announcement in @announcements
      xml.item do
        xml.title announcement.subject
        xml.description announcement.contents
        xml.pubDate announcement.published_at.to_s(:rfc822)
        xml.link url_for(announcement)
      end
    end
  end
end
