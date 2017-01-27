source 'https://rubygems.org'

ruby '2.3.1'

# Scrapers!
gem 'scrapers', git: "https://bitbucket.org/Zequez/ggfilter-scrapers.git"
# gem 'scrapers', path: '../scrapers'
# Front end client!
gem 'ggfilter_client', git: "https://bitbucket.org/Zequez/ggfilter-client-gem.git"
# gem 'ggfilter_client', path: '../client/gem'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'
# Use Posgtres as the database for Active Record
gem 'pg'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# ES6 transpiler
gem 'sprockets-es6'
# Users authentication
gem 'devise'
# Users permissions
gem 'cancancan'
# Needed by activeadmin
gem 'inherited_resources', github: 'activeadmin/inherited_resources'
# Administration panel. Cutting edge for Rails 5
gem 'activeadmin', github: 'activeadmin/activeadmin'
# Sexy HTML!
gem 'haml-rails'
# Statistics!
gem 'descriptive_statistics', '~> 2.4.0', require: 'descriptive_statistics/safe'
# Pagination!
gem 'kaminari'
# Turn blanks to nils
gem 'nilify_blanks'
# Sendgrid emails
gem 'sendgrid-ruby'
# JSON schema validation
gem 'json-schema'

group :development, :test, :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  # Use CoffeeScript for .coffee assets and views
  gem 'coffee-rails', '~> 4.1.0'
  # Annotate models with the schema information
  gem 'annotate'
  # Copy the digested fonts from the client to their original name
  gem 'non-stupid-digest-assets'
end

# Models
#####################
# Sluggification of attributes
gem 'friendly_id'
# Simple binary flags!
gem 'simple_flaggable_column'

# Other
#####################
# Use Unicorn as the app server
gem 'puma'
# Convert integers to roman numerals, for searching purposes
gem 'roman-numerals'
# Log colorization
gem 'colorize'

group :development, :test do
  # Rspec Core
  gem 'rspec-core'
  # Awesome test framework
  gem 'rspec-rails'
  # Add some RSPEC niceties
  gem 'rspec-its'
  # Mocks for RSPEC
  gem 'rspec-mocks'
  # Guard plugin for Rspec
  gem 'guard-rspec', require: false


  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Pretty prints
  gem 'awesome_print'


  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Make Rspec use spring to load faster
  gem 'spring-commands-rspec'
  # Multiple database truncation and transaction methods for tests
  gem 'database_cleaner'


  # Models factories for Rspec
  gem 'factory_girl_rails'
  # Create random text for testing, like lorem ipsum or random names
  gem 'forgery'
  # Environment variables
  gem 'dotenv-rails', :groups => [:development, :test]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :test do
  # Requests mocks
  gem 'webmock'
end

# Production
#######################

group :production do
  gem 'rails_12factor'
end
