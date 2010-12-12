# Compass setup
# To restart compass stuff from scratch:
=begin
git rm app/stylesheets/ie.sass
git rm app/stylesheets/print.sass
git rm app/stylesheets/screen.sass
git rm app/stylesheets/ie6.sass
git rm app/stylesheets/partials/
git rm public/images/button_bg.png
git rm public/images/grid.png
compass init rails --using blueprint -x sass --force .
compass install -r fancy-buttons -f fancy-buttons -x sass
=end

require 'compass'
require 'compass/app_integration/rails'
require 'fancy-buttons'
Compass::AppIntegration::Rails.initialize!
