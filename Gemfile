source 'https://rubygems.org'
#source 'http://rails-assets.org'

ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# ES6 transpiler
gem 'sprockets-es6'

group :development, :test, :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 5.0'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  # Use CoffeeScript for .coffee assets and views
  gem 'coffee-rails', '~> 4.1.0'
  # Compass bindings for Rails
  # gem 'compass-rails', github: 'Compass/compass-rails'
  # Media queries sugar
  gem 'breakpoint'
  # Grids for SASS
  gem 'susy', '~> 2.0'
end

# Other
#####################
# To parse HTML, for the scraper
gem 'nokogiri'
# Concurrent HTTP requests handler
gem 'typhoeus'
# Use Unicorn as the app server
gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Awesome test framework
  gem 'rspec-rails'
  # Guard plugin for Rspec
  gem 'guard-rspec', require: false
  # Models factories for Rspec
  gem 'factory_girl_rails'
  # Create random text for testing, like lorem ipsum or random names
  gem 'forgery'
  # BDD test framework
  gem 'capybara'
  # Add some RSPEC niceties
  gem 'rspec-its'
  # Mocks for RSPEC
  gem 'rspec-mocks'
  # Pretty prints
  gem 'awesome_print'
  # PhantomJS Test runner
  gem 'poltergeist'
  # Multiple database truncation and transaction methods for tests
  gem 'database_cleaner'
  # Handle JSON on specs
  gem 'json_spec'
end

group :test do
  gem 'webmock'                 # To fake web requests on tests
  gem 'vcr'
end

# Production
#######################

group :production do
  gem 'rails_12factor'
end
