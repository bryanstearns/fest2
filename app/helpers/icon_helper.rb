module IconHelper
  class MissingIcon < Exception
  end

  def icon_tag(name, options={})
    name = name.to_s
    options.symbolize_keys!
    options[:title] ||= name unless options[:title] == false
    options[:alt] ||= name unless options[:alt] == false
    path = "fam3silk/#{name}.png"
    raise(MissingIcon, "Not found: #{path}") \
      if RAILS_ENV != "production" and not File.exists?("#{RAILS_ROOT}/public/images/#{path}")
    image_tag path, options
  end

  def flag_icon_tag(countries, options={})
    return "" if countries.blank?
    options.symbolize_keys!
    tags = []
    countries.split(' ').each do |country|
      name = Countries.code_to_name(country) 
      unless name.blank?
        country_options = options.dup
        country_options[:title] ||= name
        country_options[:alt] ||= "#{country_options[:title]} flag"
        tags << image_tag("fam3flags/#{country.to_s}.png", country_options)
      end
    end
    tags.join(" ")
  end
  
  def country_name(country_code)
    Countries.code_to_name(country_code)
  end
end
