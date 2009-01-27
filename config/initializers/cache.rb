
options = { :namespace => "fest.#{Rails.env}" }
options[:readonly] = true if Rails.env == "test"
CACHE = MemCache.new('localhost:1211', options)

CachedModel.use_local_cache = true
CachedModel.ttl = 86400
