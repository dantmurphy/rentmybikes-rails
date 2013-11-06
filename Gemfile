# Subledger ADDED 
# Currently using Boocx Gem, will need to replace with Subledger Gem (see bottom)

source 'https://rubygems.org'

# ruby 2.0.0 required for Heroku deployment, 1.9.3 works locally
ruby '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.0'

# Use pg for db
gem 'pg'

gem 'unicorn', '4.6.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Add Boostrap
gem 'bootstrap-sass', '~> 2.0.4.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# devise for authentication
gem 'devise'

# rspec for testing
gem 'rspec-rails'

gem 'protected_attributes'

gem 'therubyracer'

gem 'less-rails'

group :development do
  gem 'debugger'
  # fix rails console error on ubuntu
  gem 'rb-readline', '~> 0.4.2'
end

gem 'balanced'

gem 'quiet_assets', group: :development

#group :production do
#  gem 'rails_12factor'
#end

# Subledger Gem
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE unless defined? OpenSSL::SSL::VERIFY_PEER
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil

source 'https://boocx:i9JHYGcWC9zjtw06@gems.boocx.com'

gem 'subledger'
