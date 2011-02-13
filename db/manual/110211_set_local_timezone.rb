require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

ManualUpdate::by('stearns') do
  # These columns are really local, but think they're UTC.
  connection = ActiveRecord::Base.connection
  {
    :announcements => [:published_at],
    :festivals => [:revised_at],
    :screenings => [:starts, :ends],
  }.each do |table_name, attributes|
    attributes.each do |attribute|
      connection.update("UPDATE #{table_name} " +
                        "SET #{attribute} = date_add(#{attribute}, interval 8 hour)")
    end
  end
end
