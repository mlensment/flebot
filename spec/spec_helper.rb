# require 'bundler'
# Bundler.require(:default, :develpment)
RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
