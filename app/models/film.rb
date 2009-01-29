class Film < CachedModel
  belongs_to :festival

  has_many :screenings, :dependent => :destroy
  has_many :picks, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :duration
  validates_presence_of :festival_id

  named_scope :on_amazon, :conditions => 'amazon_ad is not null'

  def minutes
    self[:duration] && (self[:duration] / 60)
  end
  def minutes=(m)
    self[:duration] = m.to_i * 60
  end

  def url
    festival.external_film_url(self)
  end

  def country_names(joinee=", ")
    return "" if self[:countries].nil?
    names = []
    self[:countries].split(' ').each do |c| 
      name = Countries.code_to_name(c)
      names << name unless name.blank?
    end
    names.join(joinee)
  end
  
  def country_names=(names, splitee=',')
    codes = []
    names.split(splitee).each do |n|
      c = Countries.name_to_code(n.strip)
      codes << c unless c.blank?
    end
    self[:countries] = codes.join(' ')
  end
  
  def sort_name
    # Drop leading articles. (We don't do this for foreign-language
    # articles, partly because of making mistakes on eg "Les Paul")
    name.sub(/(The|A|An)\s/, '')
  end

  def to_xml_with_options(options={})
    options[:only] ||= [:name]
    options[:methods] ||= [:url, :country_names]
    options[:include] ||= [:screenings]
    to_xml_without_options(options)
  end
  alias_method_chain :to_xml, :options

end
