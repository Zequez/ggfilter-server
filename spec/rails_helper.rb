# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'webmock/rspec'
require 'vcr'
require 'rspec/its'
require 'factory_girl'
require 'custom_logger'


include ActionDispatch::TestProcess

WebMock.disable_net_connect!(allow_localhost: true)
# Capybara.default_driver = :selenium_phantomjs
Capybara.javascript_driver = :poltergeist

Capybara.register_driver :rack_test_json do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => 'application/json' })
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.ignore_request do |request|
    URI(request.uri).host == '127.0.0.1'
  end

  # This is so we can read the response body text and
  # maybe touch it a little for edge cases
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.cassette_library_dir = "#{::Rails.root}/spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!
end

# Load the Formtastic inputs
# See https://github.com/rails/spring/issues/95

RSpec.configure do |config|
  LL.info '############################################################################################'
  config.include FactoryGirl::Syntax::Methods
  config.include JsonSpec::Helpers
  config.before(:suite) { FactoryGirl.reload }
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This is so the backtrace is shorter and only shows the project code
  # You might need to comment this out if you're doing some really hardcore debugging
  config.backtrace_exclusion_patterns << /\/gems\//

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Devise::TestHelpers, type: :controller

  # Transactions don't work with JS test drivers
  # thus we need to change the cleaning strategy to
  # truncation when we do that.

  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end


  config.around :example do |example|
    path = example.file_path.gsub(/^\.\/spec\/|_spec\.rb$/, '').split(File::SEPARATOR)
    cassette = example.metadata[:cassette]
    if cassette
      path.push(cassette) unless cassette === true
      VCR.use_cassette(path.join('/'), record: :new_episodes) do
        example.run
      end
    else
      example.run
    end
  end

  config.infer_spec_type_from_file_location!

  def response_json
    JSON.parse(response.body)
  end
end
