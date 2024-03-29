# Settings specified here will take precedence over those in config/environment.rb

# The stage environment is meant for testing finished apps that aren't 
# quite "live".

# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"
# BJS: added:
config.action_controller.asset_host                  = "http://assets%d.stage.festivalfanatic.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
