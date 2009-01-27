# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Use a different cache store?
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"
# BJS: added, to make sure the tagging & translation is working
# config.action_controller.asset_host                  = "http://assets%d.dev.festivalfanatic.com:3000"

# Care if the mailer can't send?
config.action_mailer.raise_delivery_errors = true

# BJS: Configure exception_notification
# (Normally off, unless we're debugging exceptions)
unless config.action_controller.consider_all_requests_local
  ExceptionNotifier.exception_recipients = %w(festfan@festivalfanatic.com)
  ExceptionNotifier.sender_address = %("FestivalFanatic" <festfan@festivalfanatic.com>)
end
