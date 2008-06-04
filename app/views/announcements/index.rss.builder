xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{_[:Festival]}Fanatic.com News"
    xml.description "What's new on http://#{_[:festival]}fanatic.com"
    xml.link formatted_announcements_url(:rss)
    
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
