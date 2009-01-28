
options = { :namespace => "fest.#{Rails.env}.#{SOURCE_REVISION_NUMBER}" }
options[:readonly] = true if Rails.env == "test"
CACHE = MemCache.new('localhost:1211', options)

CachedModel.use_local_cache = true
CachedModel.ttl = 4.hours
